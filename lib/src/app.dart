import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../injection/injection_container.dart';
import 'navigation/app_router.dart';
import 'store/task_store.dart';

/// Entrypoint widget that wires DI, routing, and theming.
class ToDoProApp extends StatelessWidget {
  const ToDoProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskStore>(
      create: (_) => sl<TaskStore>(),
      child: MaterialApp.router(
        title: 'ToDo Pro',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
