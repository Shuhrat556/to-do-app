import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/language_notifier.dart';
import '../store/task_store.dart';
import 'heatmap_panel.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final t = context.watch<LanguageNotifier>().translate;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        elevation: 4,
        title: Text(t('statistics_title')),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  t('statistics_description'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                HeatmapPanel(store: store),
                const SizedBox(height: 16),
                Text(
                  t('statistics_hint'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
