import 'package:isar/isar.dart';

import '../../domain/entities/completion_log.dart';
import '../../domain/entities/task_entity.dart';

part 'isar_completion_log.g.dart';

@Collection()
class IsarCompletionLog {
  IsarCompletionLog();
  Id isarId = Isar.autoIncrement;

  late String taskId;
  late String title;
  late int priority;
  late DateTime completedAt;

  CompletionLog toCompletionLog() {
    final safePriorityIndex = priority
        .clamp(0, TaskPriority.values.length - 1)
        .toInt();
    return CompletionLog(
      taskId: taskId,
      title: title,
      priority: TaskPriority.values[safePriorityIndex],
      completedAt: completedAt,
    );
  }

  factory IsarCompletionLog.fromCompletionLog(CompletionLog log) {
    final entity = IsarCompletionLog()
      ..taskId = log.taskId
      ..title = log.title
      ..priority = log.priority.index
      ..completedAt = log.completedAt;
    return entity;
  }
}
