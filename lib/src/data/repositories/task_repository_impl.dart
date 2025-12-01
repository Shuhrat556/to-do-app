import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addTask(Task task) async {
    await localDataSource.persistTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDataSource.removeTask(id);
  }

  @override
  Future<List<Task>> getAllTasks() {
    return localDataSource.fetchTasks();
  }

  @override
  Future<void> updateTask(Task task) async {
    await localDataSource.persistTask(task);
  }
}
