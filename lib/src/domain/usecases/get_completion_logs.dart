import '../entities/completion_log.dart';
import '../repositories/completion_log_repository.dart';

class GetCompletionLogs {
  final CompletionLogRepository repository;

  GetCompletionLogs(this.repository);

  Future<List<CompletionLog>> call() {
    return repository.fetchLogs();
  }
}
