import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/entities/task_entity.dart';
import '../presentation/task_localization.dart';
import '../services/notification_service.dart';
import '../store/language_notifier.dart';
import '../store/task_store.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final _notificationService = NotificationService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.init();
      _notificationService.requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final t = context.watch<LanguageNotifier>().translate;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        elevation: 4,
        title: Text(t('app_title')),
        actions: [
          IconButton(
            tooltip: t('tooltip_toggle_sort'),
            icon: Icon(
              store.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: store.toggleSortDirection,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade700,
              Colors.indigo.shade500,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _TaskOverview(t: t),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(context, t: t),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final TaskStore store;
  final String Function(String, [Map<String, String>?]) t;

  const _StatsPanel({required this.store, required this.t});

  @override
  Widget build(BuildContext context) {
    final completionPercent = store.totalTaskCount == 0
        ? 0.0
        : store.completedCount / store.totalTaskCount;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: completionPercent),
      duration: const Duration(milliseconds: 600),
      builder: (context, animatedValue, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade700,
                Colors.indigo.shade600,
                Colors.indigo.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.shade900.withOpacity(0.22),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatusCell(
                      label: t('status_done'),
                      value: store.completedCount,
                      icon: Icons.check,
                      color: Colors.greenAccent.shade400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatusCell(
                      label: t('status_pending'),
                      value: store.pendingCount,
                      icon: Icons.access_time,
                      color: Colors.orangeAccent.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t('stats_total_label', {
                        'count': store.totalTaskCount.toString(),
                      }),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    t('stats_progress_label', {
                      'percent': (completionPercent * 100).toStringAsFixed(0),
                    }),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 6,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatusCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskOverview extends StatelessWidget {
  final String Function(String, [Map<String, String>?]) t;

  const _TaskOverview({required this.t});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 12),
          sliver: SliverToBoxAdapter(child: _StatsPanel(store: store, t: t)),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 12),
          sliver: SliverToBoxAdapter(child: _buildSearchSection(store, t)),
        ),
        _buildTaskListSliver(store, t),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  Widget _buildSearchSection(
    TaskStore store,
    String Function(String, [Map<String, String>?]) t,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: store.updateSearch,
              decoration: InputDecoration(
                hintText: t('search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: TaskDisplayFilter.values.map((filter) {
                return FilterChip(
                  label: Text(t(filter.translationKey)),
                  selected: store.activeFilter == filter,
                  onSelected: (_) => store.updateFilter(filter),
                  selectedColor: Colors.indigo.shade400,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: const TextStyle(color: Colors.black87),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(t('sort_label'))),
                DropdownButton<TaskSort>(
                  value: store.sortMode,
                  onChanged: store.updateSort,
                  dropdownColor: Colors.white,
                  items: TaskSort.values
                      .map(
                        (sort) => DropdownMenuItem(
                          value: sort,
                          child: Text(t(sort.translationKey)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildTaskListSliver(
    TaskStore store,
    String Function(String, [Map<String, String>?]) t,
  ) {
    if (store.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(t('loading_tasks')),
            ],
          ),
        ),
      );
    }

    if (store.visibleTasks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            const Icon(Icons.task_alt, size: 48, color: Colors.white70),
            const SizedBox(height: 12),
            Text(t('empty_tasks')),
          ],
        ),
      ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final task = store.visibleTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
          child: _buildTaskCard(context, store, task, t),
          );
        }, childCount: store.visibleTasks.length),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TaskStore store,
    Task task,
    String Function(String, [Map<String, String>?]) t,
  ) {
    final category = task.categoryId != null
        ? store.categoryById(task.categoryId!)
        : null;
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(t('task_remove_title')),
                  content: Text(t('task_remove_message')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                    child: Text(t('dialog_cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                    child: Text(t('dialog_delete')),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (_) => context.read<TaskStore>().deleteTask(task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) =>
                  context.read<TaskStore>().toggleCompletion(task.id),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.isNotEmpty)
                  Text(task.description!),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(
                        t(task.isCompleted ? 'status_done' : 'status_pending'),
                      ),
                      avatar: Icon(
                        task.isCompleted ? Icons.check_circle : Icons.timelapse,
                        size: 18,
                        color: Colors.white,
                      ),
                      backgroundColor: task.isCompleted
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    Chip(
                      label: Text(t(task.priority.translationKey)),
                      avatar: Icon(
                        task.priority.icon,
                        size: 18,
                        color: Colors.white,
                      ),
                      backgroundColor: task.priority.color,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    if (task.dueDate != null)
                      Chip(
                        avatar: const Icon(Icons.calendar_month, size: 18),
                        label: Text(formatTaskDueDate(task.dueDate!, t)),
                      ),
                    if (category != null)
                      Chip(
                        avatar: CircleAvatar(backgroundColor: category.color),
                        label: Text(category.name),
                      ),
                    Chip(
                      avatar: const Icon(Icons.repeat, size: 18),
                      label: Text(formatTaskRecurrence(task, t)),
                    ),
                  ],
                ),
                if (task.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: task.timeProgress,
                            color: task.priority.color,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatTaskRemainingDuration(task, t),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showTaskForm(context, task: task, t: t),
            ),
            onTap: () => context.read<TaskStore>().toggleCompletion(task.id),
          ),
        ),
      ),
    );
  }
}

  Future<void> _showTaskForm(
    BuildContext context, {
    Task? task,
    required String Function(String, [Map<String, String>?]) t,
  }) async {
    final store = context.read<TaskStore>();
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    TaskPriority priority = task?.priority ?? TaskPriority.medium;
    DateTime? dueDate = task?.dueDate;
    String? selectedCategory = task?.categoryId;
    RecurrenceType recurrenceType = task?.recurrenceType ?? RecurrenceType.none;
    final intervalController = TextEditingController(
      text: task?.recurrenceIntervalDays.toString() ?? '1',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final formTitle = task == null
                  ? t('task_form_new_title')
                  : t('task_form_edit_title');
              final dueDateLabel = dueDate != null
                  ? t('task_form_due_label', {'date': dueDate!.format()})
                  : t('task_form_due_add');
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    formTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: t('task_form_title_hint'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: t('task_form_description_hint'),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: store.categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    hint: Text(t('task_form_category_hint')),
                    onChanged: (value) => setState(() {
                      selectedCategory = value;
                    }),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: TaskPriority.values.map((option) {
                      return ChoiceChip(
                        label: Text(t(option.translationKey)),
                        selected: priority == option,
                        onSelected: (_) => setState(() {
                          priority = option;
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RecurrenceType>(
                    initialValue: recurrenceType,
                    decoration: InputDecoration(
                      labelText: t('task_form_recurrence_label'),
                    ),
                    items: RecurrenceType.values
                        .map(
                          (type) {
                            final labelKey = type == RecurrenceType.interval
                                ? 'recurrence_interval_choice'
                                : type.translationKey;
                            return DropdownMenuItem(
                              value: type,
                              child: Text(t(labelKey)),
                            );
                          },
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => recurrenceType = value);
                    },
                  ),
                  if (recurrenceType == RecurrenceType.interval)
                    const SizedBox(height: 8),
                  if (recurrenceType == RecurrenceType.interval)
                    TextField(
                      controller: intervalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: t('task_form_interval_label'),
                        hintText: t('task_form_interval_hint'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(dueDateLabel),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: () async {
                        final dateTime = await _pickDueDateTime(context, dueDate);
                        if (dateTime == null) return;
                        setState(() => dueDate = dateTime);
                      },
                    ),
                    onTap: () async {
                      final dateTime = await _pickDueDateTime(context, dueDate);
                      if (dateTime == null) return;
                      setState(() => dueDate = dateTime);
                    },
                  ),
                  if (dueDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => dueDate = null),
                        child: Text(t('task_form_due_remove')),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;
                      final navigator = Navigator.of(context);
                      final now = DateTime.now();
                      final parsedInterval =
                          int.tryParse(intervalController.text) ?? 1;
                      final recurrenceInterval =
                          recurrenceType == RecurrenceType.interval
                              ? parsedInterval.clamp(1, 365)
                              : 1;
                      if (task == null) {
                        final newTask = Task(
                          id: now.microsecondsSinceEpoch.toString(),
                          title: title,
                          description: descriptionController.text.trim(),
                          dueDate: dueDate,
                          isCompleted: false,
                          categoryId: selectedCategory,
                          priority: priority,
                          createdAt: now,
                          updatedAt: now,
                          recurrenceType: recurrenceType,
                          recurrenceIntervalDays: recurrenceInterval,
                        );
                        await store.addTask(newTask);
                      } else {
                        final updated = task.copyWith(
                          title: title,
                          description: descriptionController.text.trim(),
                          dueDate: dueDate,
                          categoryId: selectedCategory,
                          priority: priority,
                          updatedAt: now,
                          recurrenceType: recurrenceType,
                          recurrenceIntervalDays: recurrenceInterval,
                        );
                        await store.updateTask(updated);
                      }
                      navigator.pop();
                    },
                    child: Text(
                      task == null
                          ? t('task_form_save')
                          : t('task_form_save_changes'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
    
      );
    },
  );
}

Future<DateTime?> _pickDueDateTime(
  BuildContext context,
  DateTime? current,
) async {
  final date = await showDatePicker(
    context: context,
    initialDate: current ?? DateTime.now(),
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
  );
  if (date == null) return current;
  if (!context.mounted) return current;
  final initialTime = TimeOfDay(
    hour: current?.hour ?? 9,
    minute: current?.minute ?? 0,
  );
  final time = await showTimePicker(context: context, initialTime: initialTime);
  if (time == null) return current;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
