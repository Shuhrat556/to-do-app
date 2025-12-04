import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      child: Consumer<LanguageNotifier>(
        builder: (context, language, _) => MaterialApp.router(
          locale: language.locale,
          supportedLocales: language.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: 'ToDo Pro',
          themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo.shade900,
            elevation: 4,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo.shade900,
            elevation: 4,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
          builder: (context, child) =>
              LockGate(child: child ?? const SizedBox()),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
