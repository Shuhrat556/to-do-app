import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/entities/task_entity.dart';
import '../store/language_notifier.dart';
import '../store/task_store.dart';

class HeatmapPanel extends StatelessWidget {
  final TaskStore store;

  const HeatmapPanel({super.key, required this.store});

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
    final t = context.watch<LanguageNotifier>().translate;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F9FF), Color(0xFFE6EDFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade900.withOpacity(0.18),
            offset: const Offset(0, 15),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('heatmap_panel_title'),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            t('heatmap_panel_subtitle'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(
                        now.year.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: Colors.indigo.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  t('heatmap_description'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade900.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildHeatmapScroll(
                    context,
                    entries,
                    minDate,
                    maxDate,
                    t,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LegendCircle(color: Colors.indigo, label: t('legend_completed')),
                    LegendCircle(color: Colors.indigoAccent, label: t('legend_few')),
                    LegendCircle(color: const Color(0xFFB3C5FF), label: t('legend_none')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapScroll(
    BuildContext context,
    List<ContributionEntry> entries,
    DateTime minDate,
    DateTime maxDate,
    String Function(String, [Map<String, String>?]) t,
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
                  _showHeatmapDetails(context, store, date, value, t),
            ),
          ),
        ),
      ),
    );
  }
}

class LegendCircle extends StatelessWidget {
  final Color color;
  final String label;

  const LegendCircle({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

Future<void> _showHeatmapDetails(
  BuildContext context,
  TaskStore store,
  DateTime date,
  int value,
  String Function(String, [Map<String, String>?]) t,
) async {
  final logs = store.completionLogsForDate(date);
  final dateLabel =
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final listHeight = logs.isEmpty
          ? 120.0
          : (logs.length * 64.0).clamp(120.0, 320.0);
      final header = value > 0
          ? t('heatmap_details_header', {'count': value.toString()})
          : t('heatmap_details_empty');
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
              t('heatmap_details_date', {'date': dateLabel}),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(header, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  t('heatmap_details_empty'),
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
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade600,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      title: Text(log.title),
                      subtitle: Text(log.completedAt.format()),
                      trailing: Text(
                        t(log.priority.translationKey),
                        style: TextStyle(color: log.priority.color),
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

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
