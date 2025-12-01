
1. Project Overview

Name: ToDo Pro (working title)
Platforms: Android & iOS
Framework: Flutter
Architecture: Clean Architecture + BLoC + Dependency Injection (get_it)

The app is a modern task manager that supports:

Task creation, editing, completion, deletion

Deadlines & reminders

Categories/Projects

Priority levels

Search, filters, sorting

Calendar view

Light/Dark theme

(Optional later) Cloud sync, shared lists, widgets, voice input

2. Tech Stack

Language: Dart

Framework: Flutter

State Management: flutter_bloc

Architecture pattern: Clean Architecture (Presentation / Domain / Data)

DI Container: get_it

Value Equality: equatable

Local Database: isar

Local Notifications: flutter_local_notifications (or similar)

(Optional) Cloud Sync: Firebase (Firestore + Auth) or Supabase

3. Clean Architecture Layers
3.1. Presentation Layer

Technology: Flutter UI + BLoC

Responsibility:

Render screens and widgets

React to user input

Listen to BLoC states and display UI accordingly

Trigger events to BLoCs

Main elements:

Screens (Pages)

Widgets

Bloc / Cubit classes

BlocBuilder, BlocListener, MultiBlocProvider

3.2. Domain Layer

Pure Dart, no Flutter imports.

Responsibility:

Business rules and app logic

Use cases (interactors)

Entities and value objects

Repository interfaces (abstract)

Main elements:

Entities (e.g. Task, Category, User)

UseCases (e.g. CreateTask, GetTasks, CompleteTask)

Repositories (abstract interfaces to be implemented by Data layer)

3.3. Data Layer

Responsibility:

Implement repositories

Handle data sources (local DB, remote API)

Mapping between domain entities and data models

Main elements:

Local Data Source: Isar models and queries

(Optional) Remote Data Source: Firebase / REST API

DTOs / models

Repository implementations

4. Proposed Folder Structure
lib/
  core/
    error/
    usecase/
    utils/
    constants/
  features/
    tasks/
      presentation/
        bloc/
        pages/
        widgets/
      domain/
        entities/
        repositories/
        usecases/
      data/
        models/
        datasources/
        repositories/
    auth/ (optional for cloud sync)
    settings/
  injection/
    injection_container.dart
  main.dart

5. Entities & Data Model
5.1. Task Entity (Domain)
class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? categoryId;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    isCompleted,
    categoryId,
    priority,
    createdAt,
    updatedAt,
  ];
}

enum TaskPriority { low, medium, high }

5.2. Category Entity
class Category extends Equatable {
  final String id;
  final String name;
  final int colorValue; // store Color as int

  @override
  List<Object?> get props => [id, name, colorValue];
}

5.3. (Optional) User Entity (for cloud sync)
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}

6. Core Features (Functional Requirements)
6.1. Task CRUD

Create Task

Fields: title (required), description (optional), due date (optional), category (optional), priority (default = Medium)

Validate empty title

Edit Task

User can modify all fields

Delete Task

Permanent delete from database

Mark Task as Completed / Uncompleted

Toggle isCompleted flag

Completed tasks shown with visual difference (strikethrough, faded, etc.)

6.2. Deadlines & Reminders

Tasks can have an optional dueDate

User can add a reminder notification at:

Exact time (e.g. 15:00)

Or presets: 10/30 min before, 1 hour before, 1 day before

Use local notifications to trigger OS-level notification

6.3. Categories / Projects

User can create, edit, delete categories

Each task can belong to 0 or 1 category

Filter tasks by category

Category color displayed in UI (e.g. small colored dot/label)

6.4. Priority Levels

Enum: Low, Medium, High

Visual indicator (e.g. icon, small chip)

Sort by priority (High → Low)

6.5. Search

Search bar at top of task list

Search by:

Title

Description

Search should be local (on existing stored tasks)

6.6. Filters & Sorting

Filter options:

All tasks

Only active (not completed)

Only completed

Today’s tasks

Overdue tasks

By category

Sorting options:

By due date (ascending/descending)

By created date

By priority

6.7. Calendar View

Monthly calendar screen

On date tap: show list of tasks for that date

Indicate days that have tasks (small dots or markers)

6.8. Theming

Light & Dark theme

Follow system theme by default

Option in settings to force Light or Dark

6.9. (Optional V2) Cloud Sync

Sign-in with email/password / Google / Apple

Sync tasks and categories across devices

Conflict resolution strategy:

Last-write-wins by default

Offline-first:

Write to Isar

Sync to remote when online

6.10. (Optional V2) Shared Lists

Share a project/category with other users

All members see and modify shared tasks

Roles: owner, member

6.11. (Optional V2) Widgets

Home screen widget (Android, iOS)

Show today’s tasks

Quick add button

6.12. (Optional V2) Voice Input

Button “Add task by voice”

Use speech-to-text to fill task title

7. Use Cases (Domain Layer)

Examples (each use case = one class):

CreateTask

UpdateTask

DeleteTask

ToggleTaskCompletion

GetAllTasks

GetTasksByDate

GetTasksByCategory

SearchTasks

CreateCategory

GetAllCategories

DeleteCategory

(optional) SyncTasks, SignIn, SignOut, etc.

Each use case returns Either<Failure, Result> or similar pattern.

8. BLoCs (Presentation Layer)

Example BLoCs:

TaskListBloc

Events: LoadTasks, FilterChanged, SearchTextChanged, TaskToggled, TaskDeleted

States: TaskListLoading, TaskListLoaded, TaskListError

TaskDetailBloc / TaskFormBloc

Events: TitleChanged, DescriptionChanged, DueDateChanged, PriorityChanged, CategoryChanged, SubmitPressed

States: form states + submission status

CategoryBloc

Manage categories (CRUD)

SettingsBloc

Manage theme, preferences, etc.

All Event and State classes implement Equatable.

9. Dependency Injection (get_it)

Use a single injection_container.dart (or service_locator.dart)

Register:

BLoCs (as factory)

UseCases (as lazySingleton)

Repository implementations

Data sources (Isar local, optional remote)

Isar instance

Example:

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => TaskListBloc(
        getAllTasks: sl(),
        toggleTaskCompletion: sl(),
        deleteTask: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => ToggleTaskCompletion(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(), // optional
    ),
  );

  // Data sources, DB, etc.
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(isar: sl()),
  );

  // Isar init
  final isar = await Isar.open([...models]);
  sl.registerLazySingleton<Isar>(() => isar);
}

10. Non-Functional Requirements

Performance:

List scrolling must be smooth even with 1000+ tasks

All DB operations must be asynchronous

Reliability:

App should handle app restarts without losing data (Isar DB)

Graceful error handling with user-friendly messages

Scalability:

Easy to add new features (e.g. tags, attachments) thanks to Clean Architecture

Testability:

Unit tests for use cases and repositories

BLoC tests for critical flows



contribution_heatmap: ^0.4.2