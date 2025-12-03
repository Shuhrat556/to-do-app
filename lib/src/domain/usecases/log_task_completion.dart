import '../entities/completion_log.dart';
import '../repositories/completion_log_repository.dart';

class LogTaskCompletion {
  final CompletionLogRepository repository;

  LogTaskCompletion(this.repository);

  Future<void> call(CompletionLog log) {
    return repository.addLog(log);
  }
}
