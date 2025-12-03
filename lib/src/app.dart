import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../injection/injection_container.dart';
import 'navigation/app_router.dart';
import 'presentation/lock_gate.dart';
import 'store/language_notifier.dart';
import 'store/lock_notifier.dart';
import 'store/task_store.dart';

/// Entrypoint widget that wires DI, routing, and theming.
class ToDoProApp extends StatelessWidget {
  const ToDoProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskStore>(create: (_) => sl<TaskStore>()),
        ChangeNotifierProvider<LockNotifier>(create: (_) => sl<LockNotifier>()),
        ChangeNotifierProvider<LanguageNotifier>(
          create: (_) => sl<LanguageNotifier>(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
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
        builder: (context, child) => LockGate(child: child ?? const SizedBox()),
        routerConfig: appRouter,
      ),
    );
  }
}
