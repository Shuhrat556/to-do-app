import 'package:isar/isar.dart';

import '../../domain/entities/task_entity.dart';
import '../models/isar_task.dart';

abstract class TaskLocalDataSource {
  Future<List<Task>> fetchTasks();
  Future<void> persistTask(Task task);
  Future<void> removeTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Isar isar;

  TaskLocalDataSourceImpl({required this.isar});

  @override
  Future<List<Task>> fetchTasks() async {
    final isarTasks = await isar.isarTasks.where().findAll();
    return isarTasks.map((e) => e.toTask()).toList();
  }

  @override
  Future<void> persistTask(Task task) async {
    final entity = IsarTask.fromTask(task);
    await isar.writeTxn(() => isar.isarTasks.put(entity));
  }

  @override
  Future<void> removeTask(String id) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.isarTasks.filter().taskIdEqualTo(id).findFirst();
      if (entity != null) {
        await isar.isarTasks.delete(entity.isarId);
      }
    });
  }
}
