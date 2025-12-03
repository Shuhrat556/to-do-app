import '../../domain/entities/completion_log.dart';
import '../../domain/repositories/completion_log_repository.dart';
import '../datasources/completion_log_local_data_source.dart';

class CompletionLogRepositoryImpl implements CompletionLogRepository {
  final CompletionLogLocalDataSource localDataSource;

  CompletionLogRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addLog(CompletionLog log) {
    return localDataSource.addCompletionLog(log);
  }

  @override
  Future<List<CompletionLog>> fetchLogs() {
    return localDataSource.fetchCompletionLogs();
  }
}
