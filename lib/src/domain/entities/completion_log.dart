import 'package:flutter/foundation.dart';

import 'task_entity.dart';

@immutable
class CompletionLog {
  final String taskId;
  final String title;
  final TaskPriority priority;
  final DateTime completedAt;

  const CompletionLog({
    required this.taskId,
    required this.title,
    required this.priority,
    required this.completedAt,
  });
}
