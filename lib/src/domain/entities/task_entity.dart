import 'package:flutter/material.dart';

enum RecurrenceType { none, daily, interval }

extension RecurrenceTypeInfo on RecurrenceType {
  String get translationKey => 'recurrence_$name';
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? categoryId;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RecurrenceType recurrenceType;
  final int recurrenceIntervalDays;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.isCompleted,
    this.categoryId,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceIntervalDays = 1,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? categoryId,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    RecurrenceType? recurrenceType,
    int? recurrenceIntervalDays,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceIntervalDays:
          recurrenceIntervalDays ?? this.recurrenceIntervalDays,
    );
  }

  Duration get remainingDuration =>
      dueDate?.difference(DateTime.now()) ?? Duration.zero;

  double get timeProgress {
    if (dueDate == null) return 0;
    final totalDuration =
        dueDate!.difference(createdAt).inSeconds.toDouble().clamp(1, double.infinity);
    final remainingSeconds = remainingDuration.inSeconds.toDouble();
    return (remainingSeconds / totalDuration).clamp(0, 1).toDouble();
  }

  // Strings are handled in the presentation layer to keep the domain layer agnostic.
}

enum TaskPriority { low, medium, high }

extension TaskPriorityInfo on TaskPriority {
  String get translationKey => 'task_priority_$name';

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.high:
        return Colors.red.shade400;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
    }
  }
}

class Category {
  final String id;
  final String name;
  final int colorValue;

  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}

extension DateTimeHelpers on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  String format() {
    final dayText = day.toString().padLeft(2, '0');
    final monthText = month.toString().padLeft(2, '0');
    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$dayText.$monthText.$year, $hourText:$minuteText';
  }
}
