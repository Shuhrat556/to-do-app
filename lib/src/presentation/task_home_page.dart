import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/entities/task_entity.dart';
import '../services/notification_service.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ToDo Pro'),
        actions: [
          IconButton(
            tooltip: 'Toggle sort direction',
            icon: Icon(context.watch<TaskStore>().ascending
                ? Icons.arrow_upward
                : Icons.arrow_downward),
            onPressed: context.read<TaskStore>().toggleSortDirection,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            child: _TaskOverview(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final TaskStore store;

  const _StatsPanel({required this.store});

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
                      label: 'Bajarilgan',
                      value: store.completedCount,
                      icon: Icons.check,
                      color: Colors.greenAccent.shade400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatusCell(
                      label: 'Qolgan',
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
                      'Umumiy: ${store.totalTaskCount}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${(completionPercent * 100).toStringAsFixed(0)}% bajarilgan',
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
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

class _HeatmapPanel extends StatelessWidget {
  final TaskStore store;

  const _HeatmapPanel({required this.store});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minDate = DateTime(now.year, 1, 1);
    final maxDate = DateTime(now.year, now.month, now.day);
    final entries = store.contributionEntries
        .where((entry) => entry.date.year == now.year)
        .toList();
    if (entries.isEmpty) {
      entries.add(ContributionEntry(now, 0));
    }

    return Card(
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Joriy yil holati',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHeatmapScroll(context, entries, minDate, maxDate),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapScroll(
    BuildContext context,
    List<ContributionEntry> entries,
    DateTime minDate,
    DateTime maxDate,
  ) {
    const cellSize = 14.0;
    const cellSpacing = 2.0;
    const columnEstimate = 56;
    final estimatedWidth = columnEstimate * (cellSize + cellSpacing);
    return SizedBox(
      height: 200,
      child: ScrollConfiguration(
        behavior: const _NoGlowScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: estimatedWidth,
            child: ContributionHeatmap(
              entries: entries,
              minDate: minDate,
              maxDate: maxDate,
              heatmapColor: HeatmapColor.indigo,
              cellSize: cellSize,
              cellSpacing: cellSpacing,
              cellRadius: 4,
              padding: EdgeInsets.zero,
              showWeekdayLabels: false,
              splittedMonthView: false,
              monthTextStyle: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                letterSpacing: 0.3,
              ),
              weekdayTextStyle: const TextStyle(
                fontSize: 10,
                color: Colors.black38,
              ),
              onCellTap: (date, value) =>
                  _showHeatmapDetails(context, store, date, value),
            ),
          ),
        ),
      ),
    );
  }
}


class _TaskOverview extends StatelessWidget {
  const _TaskOverview();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 12),
          sliver: SliverToBoxAdapter(child: _StatsPanel(store: store)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          sliver: SliverToBoxAdapter(child: _HeatmapPanel(store: store)),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 12),
          sliver: SliverToBoxAdapter(child: _buildSearchSection(store)),
        ),
        _buildTaskListSliver(store),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  Widget _buildSearchSection(TaskStore store) {
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
                hintText: 'Qidirish vazifalar ichida',
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
                  label: Text(filter.label),
                  selected: store.activeFilter == filter,
                  onSelected: (_) => store.updateFilter(filter),
                  selectedColor: Colors.indigo.shade400,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Saralash:')),
                DropdownButton<TaskSort>(
                  value: store.sortMode,
                  onChanged: store.updateSort,
                  dropdownColor: Colors.white,
                  items: TaskSort.values
                      .map(
                        (sort) => DropdownMenuItem(
                          value: sort,
                          child: Text(sort.label),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Eslatma tovushini yoqing'),
              subtitle: const Text('Muddat tugagach signal chiqsin'),
              value: store.useAlarmTone,
              onChanged: store.updateReminderStyle,
            ),
          ],
        ),
      ),
    );
  }

   _buildTaskListSliver(TaskStore store) {
    if (store.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Vazifalar yuklanmoqda...'),
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
            children: const [
              Icon(Icons.task_alt, size: 48, color: Colors.white70),
              SizedBox(height: 12),
              Text('Hozircha vazifalar yo‘q.'),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final task = store.visibleTasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTaskCard(context, store, task),
            );
          },
          childCount: store.visibleTasks.length,
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskStore store, Task task) {
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
                  title: const Text('Vazifani o‘chirish'),
                  content: const Text('Vazifani olib tashlamoqchimisiz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Bekor qilish'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('O‘chirish'),
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
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null &&
                    task.description!.isNotEmpty)
                  Text(task.description!),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(task.isCompleted
                          ? 'Bajarilgan'
                          : 'Kutilmoqda'),
                      avatar: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.timelapse,
                        size: 18,
                        color: Colors.white,
                      ),
                      backgroundColor: task.isCompleted
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    Chip(
                      label: Text(task.priority.label),
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
                        label: Text(task.dueDateLabel),
                      ),
                    if (category != null)
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: category.color,
                        ),
                        label: Text(category.name),
                      ),
                    Chip(
                      avatar: const Icon(Icons.repeat, size: 18),
                      label: Text(task.recurrenceLabel),
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
                          task.remainingDurationLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showTaskForm(context, task: task),
            ),
            onTap: () => context
                .read<TaskStore>()
                .toggleCompletion(task.id),
          ),
        ),
      ),
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}


Future<void> _showTaskForm(BuildContext context, {Task? task}) async {
  final store = context.read<TaskStore>();
  final titleController = TextEditingController(text: task?.title ?? '');
  final descriptionController =
      TextEditingController(text: task?.description ?? '');
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
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  task == null ? 'Yangi vazifa' : 'Vazifani o‘zgartirish',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Sarlavha',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Tavsif (ixtiyoriy)',
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
                  hint: const Text('Kategoriya'),
                  onChanged: (value) => setState(() {
                    selectedCategory = value;
                  }),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: TaskPriority.values.map((option) {
                    return ChoiceChip(
                      label: Text(option.label),
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
                  decoration: const InputDecoration(
                    labelText: 'Takrorlash turi',
                  ),
                  items: RecurrenceType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
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
                    decoration: const InputDecoration(
                      labelText: 'Har necha kunda',
                      hintText: 'Masalan: 3',
                    ),
                  ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    dueDate != null
                        ? 'Muddat: ${dueDate?.format()}'
                        : 'Muddatni qo‘shish',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () async {
                      final date = await _pickDate(context, dueDate);
                      if (date == null) return;
                      setState(() => dueDate = date);
                    },
                  ),
                  onTap: () async {
                    final date = await _pickDate(context, dueDate);
                    if (date == null) return;
                    setState(() => dueDate = date);
                  },
                ),
                if (dueDate != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => dueDate = null),
                      child: const Text('Muddatni olib tashlash'),
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
                    final recurrenceInterval = recurrenceType == RecurrenceType.interval
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
                  child:
                      Text(task == null ? 'Saqlash' : 'O‘zgarishlarni saqlash'),
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

Future<DateTime?> _pickDate(BuildContext context, DateTime? current) async {
  final date = await showDatePicker(
    context: context,
    initialDate: current ?? DateTime.now(),
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
  );
  if (date == null) return current;
  final baseHour = current?.hour ?? 9;
  final baseMinute = current?.minute ?? 0;
  return DateTime(
    date.year,
    date.month,
    date.day,
    baseHour,
    baseMinute,
  );
}

Future<void> _showHeatmapDetails(
  BuildContext context,
  TaskStore store,
  DateTime date,
  int value,
) async {
  final tasks = store.completedTasksForDate(date);
  final dateLabel = '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final listHeight = tasks.isEmpty
          ? 120.0
          : (tasks.length * 64.0).clamp(120.0, 320.0);
      final header = value > 0
          ? '$value ta vazifa bajarildi'
          : 'Bu kunda vazifa bajarilmadi';
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sana: $dateLabel',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              header,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Bu kunda hali bajarilgan vazifa yo‘q.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              SizedBox(
                height: listHeight,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade600,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      title: Text(task.title),
                      subtitle: Text(task.updatedAt.format()),
                      trailing: Text(
                        task.priority.label,
                        style: TextStyle(color: task.priority.color),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
