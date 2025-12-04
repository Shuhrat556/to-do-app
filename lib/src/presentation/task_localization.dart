import '../domain/entities/task_entity.dart';

String formatTaskDueDate(
  DateTime date,
  String Function(String, [Map<String, String>?]) t,
) {
  return t('task_form_due_label', {'date': date.format()});
}

String formatTaskRecurrence(
  Task task,
  String Function(String, [Map<String, String>?]) t,
) {
  switch (task.recurrenceType) {
    case RecurrenceType.none:
      return t('recurrence_none');
    case RecurrenceType.daily:
      return t('recurrence_daily');
    case RecurrenceType.interval:
      return t('recurrence_interval', {
        'interval': task.recurrenceIntervalDays.toString(),
      });
  }
}

String formatTaskRemainingDuration(
  Task task,
  String Function(String, [Map<String, String>?]) t,
) {
  if (task.dueDate == null) return '';
  final remaining = task.remainingDuration;
  if (remaining.isNegative) {
    return t('task_remaining_overdue');
  }
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes % 60;
  if (hours > 0) {
    return t('task_remaining_hours', {
      'hours': hours.toString(),
      'minutes': minutes.toString(),
    });
  }
  if (minutes > 0) {
    return t('task_remaining_minutes', {'minutes': minutes.toString()});
  }
  return t('task_remaining_now');
}
