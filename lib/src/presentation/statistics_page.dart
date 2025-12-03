import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/task_store.dart';
import 'heatmap_panel.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Statistika'),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Joriy yil davomida bajarilgan vazifalaringizni kuzatib boring.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                HeatmapPanel(store: store),
                const SizedBox(height: 16),
                Text(
                  'Yulduzlar har bir vazifa natijasida to‘planadi; ustun ustiga bosib batafsil ko‘rishingiz mumkin.',
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
