import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../src/data/datasources/completion_log_local_data_source.dart';
import '../src/data/datasources/task_local_data_source.dart';
import '../src/data/models/isar_completion_log.dart';
import '../src/data/models/isar_task.dart';
import '../src/data/repositories/completion_log_repository_impl.dart';
import '../src/data/repositories/task_repository_impl.dart';
import '../src/domain/repositories/completion_log_repository.dart';
import '../src/domain/repositories/task_repository.dart';
import '../src/domain/usecases/create_task.dart';
import '../src/domain/usecases/delete_task.dart';
import '../src/domain/usecases/get_completion_logs.dart';
import '../src/domain/usecases/get_tasks.dart';
import '../src/domain/usecases/log_task_completion.dart';
import '../src/domain/usecases/update_task.dart';
import '../src/services/language_service.dart';
import '../src/services/lock_service.dart';
import '../src/store/language_notifier.dart';
import '../src/store/lock_notifier.dart';
import '../src/store/task_store.dart';

final sl = GetIt.instance;

Future<void> init({String? directoryPath}) async {
  final targetDirectory = directoryPath != null
      ? Directory(directoryPath)
      : await getApplicationSupportDirectory();
  await targetDirectory.create(recursive: true);
  final isar = await Isar.open([
    IsarTaskSchema,
    IsarCompletionLogSchema,
  ], directory: targetDirectory.path);

  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<CompletionLogLocalDataSource>(
    () => CompletionLogLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CompletionLogRepository>(
    () => CompletionLogRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LockService>(() => LockService());
  sl.registerLazySingleton<LanguageService>(() => LanguageService());

  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => GetCompletionLogs(sl()));
  sl.registerLazySingleton(() => LogTaskCompletion(sl()));
  sl.registerFactory(() => LockNotifier(sl()));
  sl.registerFactory(() => LanguageNotifier(sl()));

  sl.registerFactory(
    () => TaskStore(
      getTasksUseCase: sl(),
      createTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      getCompletionLogsUseCase: sl(),
      logTaskCompletionUseCase: sl(),
    ),
  );
}
