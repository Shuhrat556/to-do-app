import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:flutter/material.dart';

import '../domain/entities/completion_log.dart';
import '../domain/entities/task_entity.dart';
import '../domain/usecases/create_task.dart';
import '../domain/usecases/delete_task.dart';
import '../domain/usecases/get_completion_logs.dart';
import '../domain/usecases/get_tasks.dart';
import '../domain/usecases/log_task_completion.dart';
import '../domain/usecases/update_task.dart';
import '../services/notification_service.dart';

class TaskStore extends ChangeNotifier {
  final GetTasks getTasksUseCase;
  final CreateTask createTaskUseCase;
  final UpdateTask updateTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final GetCompletionLogs getCompletionLogsUseCase;
  final LogTaskCompletion logTaskCompletionUseCase;

  TaskStore({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getCompletionLogsUseCase,
    required this.logTaskCompletionUseCase,
  }) {
    _initialize();
  }

  static const Category _unknownCategory = Category(
    id: 'unknown',
    name: 'Belgilanmagan',
    colorValue: 0xFF9E9E9E,
  );

  final List<Category> _categories = const [
    Category(id: 'personal', name: 'Shaxsiy', colorValue: 0xFF42A5F5),
    Category(id: 'work', name: 'Ish', colorValue: 0xFF9C27B0),
    Category(id: 'learning', name: 'O‘rganish', colorValue: 0xFF26A69A),
  ];

  final List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchTerm = '';
  TaskDisplayFilter _activeFilter = TaskDisplayFilter.all;
  TaskSort _sortMode = TaskSort.dueDate;
  bool _ascending = true;
  bool _useAlarmTone = true;
  final NotificationService _notificationService = NotificationService.instance;
  final List<CompletionLog> _completionLogs = [];

  List<Category> get categories => List.unmodifiable(_categories);
  TaskDisplayFilter get activeFilter => _activeFilter;
  TaskSort get sortMode => _sortMode;
  bool get ascending => _ascending;
  bool get useAlarmTone => _useAlarmTone;
  bool get isLoading => _isLoading;
  int get totalTaskCount => _tasks.length;
  int get completedCount => _tasks.where((task) => task.isCompleted).length;
  int get pendingCount => totalTaskCount - completedCount;
  double get completionRate =>
      totalTaskCount == 0 ? 0 : completedCount / totalTaskCount;
  List<ContributionEntry> get contributionEntries {
    final entries = _completionCounts.entries
        .map((entry) => ContributionEntry(entry.key, entry.value))
        .toList();
    entries.sort((a, b) => a.date.compareTo(b.date));
    if (entries.isEmpty) {
      final today = _startOfDay(DateTime.now());
      entries.add(ContributionEntry(today, 0));
    }
    return entries;
  }

  List<Task> get visibleTasks {
    if (_isLoading) {
      return [];
    }

    final now = DateTime.now();
    final base = _tasks.where((task) {
      if (_searchTerm.isNotEmpty) {
        final text = _searchTerm.toLowerCase();
        final inTitle = task.title.toLowerCase().contains(text);
        final inDescription =
            task.description?.toLowerCase().contains(text) ?? false;
        if (!inTitle && !inDescription) return false;
      }
      switch (_activeFilter) {
        case TaskDisplayFilter.all:
          return true;
        case TaskDisplayFilter.active:
          return !task.isCompleted;
        case TaskDisplayFilter.completed:
          return task.isCompleted;
        case TaskDisplayFilter.today:
          return task.dueDate != null && task.dueDate!.isSameDay(now);
        case TaskDisplayFilter.overdue:
          return task.dueDate != null &&
              task.dueDate!.isBefore(now) &&
              !task.isCompleted;
      }
    }).toList();

    base.sort((a, b) {
      late int result;
      switch (_sortMode) {
        case TaskSort.dueDate:
          result = (a.dueDate ?? DateTime(2100)).compareTo(
            b.dueDate ?? DateTime(2100),
          );
          break;
        case TaskSort.createdAt:
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case TaskSort.priority:
          result = a.priority.index.compareTo(b.priority.index);
          break;
      }
      return _ascending ? result : -result;
    });

    return base;
  }

  List<CompletionLog> get completionLogs => List.unmodifiable(_completionLogs);

  Future<void> _initialize() async {
    await _loadTasks();
    await _loadCompletionLogs();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();
    final tasks = await getTasksUseCase.call();
    _tasks
      ..clear()
      ..addAll(tasks);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCompletionLogs() async {
    final logs = await getCompletionLogsUseCase.call();
    _completionLogs
      ..clear()
      ..addAll(logs);
    _completionLogs.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await createTaskUseCase.call(task);
    _tasks.add(task);
    await _syncNotification(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await updateTaskUseCase.call(task);
    final index = _tasks.indexWhere((element) => element.id == task.id);
    if (index == -1) return;
    final current = _tasks[index];
    final shouldLogCompletion = !current.isCompleted && task.isCompleted;
    _tasks[index] = task;
    await _syncNotification(task);
    if (shouldLogCompletion) {
      await _recordTaskCompletion(task);
    }
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await deleteTaskUseCase.call(id);
    _tasks.removeWhere((task) => task.id == id);
    await _notificationService.cancelNotification(id);
    notifyListeners();
  }

  Future<void> toggleCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    final current = _tasks[index];
    final updated = current.copyWith(
      isCompleted: !current.isCompleted,
      updatedAt: DateTime.now(),
    );
    await updateTaskUseCase.call(updated);
    _tasks[index] = updated;
    if (updated.isCompleted) {
      await _notificationService.cancelNotification(id);
      await _recordTaskCompletion(updated);
    } else {
      await _syncNotification(updated);
    }
    notifyListeners();
  }

  Map<DateTime, int> get _completionCounts {
    final counts = <DateTime, int>{};
    for (final log in _completionLogs) {
      final day = _startOfDay(log.completedAt);
      counts.update(day, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  List<CompletionLog> completionLogsForDate(DateTime date) {
    final day = _startOfDay(date);
    final logs = _completionLogs
        .where((log) => _startOfDay(log.completedAt) == day)
        .toList();
    logs.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return logs;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _syncNotification(Task task) async {
    await _notificationService.cancelNotification(task.id);
    if (task.dueDate == null) return;
    if (task.dueDate!.isBefore(DateTime.now())) return;
    await _notificationService.scheduleTaskNotification(
      task,
      playSound: useAlarmTone,
    );
  }

  Future<void> _recordTaskCompletion(Task task) async {
    final log = CompletionLog(
      taskId: task.id,
      title: task.title,
      priority: task.priority,
      completedAt: task.updatedAt,
    );
    await logTaskCompletionUseCase.call(log);
    _completionLogs.add(log);
  }

  void updateSearch(String value) {
    _searchTerm = value;
    notifyListeners();
  }

  void updateFilter(TaskDisplayFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void updateSort(TaskSort? sort) {
    if (sort == null) return;
    _sortMode = sort;
    notifyListeners();
  }

  void toggleSortDirection() {
    _ascending = !_ascending;
    notifyListeners();
  }

  void updateReminderStyle(bool useAlarm) {
    _useAlarmTone = useAlarm;
    notifyListeners();
  }

  Category categoryById(String id) => _categories.firstWhere(
    (category) => category.id == id,
    orElse: () => _unknownCategory,
  );
}

enum TaskDisplayFilter { all, active, completed, today, overdue }

extension TaskDisplayFilterInfo on TaskDisplayFilter {
  String get translationKey => 'filter_$name';
}

enum TaskSort { dueDate, createdAt, priority }

extension TaskSortInfo on TaskSort {
  String get translationKey => 'sort_$name';
}
