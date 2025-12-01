import 'package:isar/isar.dart';

import '../../domain/entities/task_entity.dart';

part 'isar_task.g.dart';

@Collection()
class IsarTask {
  IsarTask();
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String taskId;

  late String title;
  String? description;
  DateTime? dueDate;
  late bool isCompleted;
  String? categoryId;
  late int priority;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int recurrenceType;
  late int recurrenceIntervalDays;

  Task toTask() {
    final safePriorityIndex =
        priority.clamp(0, TaskPriority.values.length - 1).toInt();
    final safeRecurrenceIndex =
        recurrenceType.clamp(0, RecurrenceType.values.length - 1).toInt();
    final safeInterval = recurrenceIntervalDays < 1 ? 1 : recurrenceIntervalDays;
    return Task(
      id: taskId,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted,
      categoryId: categoryId,
      priority: TaskPriority.values[safePriorityIndex],
      createdAt: createdAt,
      updatedAt: updatedAt,
      recurrenceType: RecurrenceType.values[safeRecurrenceIndex],
      recurrenceIntervalDays: safeInterval,
    );
  }

  factory IsarTask.fromTask(Task task) {
    final entity = IsarTask()
      ..taskId = task.id
      ..title = task.title
      ..description = task.description
      ..dueDate = task.dueDate
      ..isCompleted = task.isCompleted
      ..categoryId = task.categoryId
      ..priority = task.priority.index
      ..createdAt = task.createdAt
      ..updatedAt = task.updatedAt;
    entity.recurrenceType = task.recurrenceType.index;
    entity.recurrenceIntervalDays = task.recurrenceIntervalDays;
    return entity;
  }
}
