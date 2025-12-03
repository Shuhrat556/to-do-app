import '../entities/completion_log.dart';

abstract class CompletionLogRepository {
  Future<void> addLog(CompletionLog log);
  Future<List<CompletionLog>> fetchLogs();
}
