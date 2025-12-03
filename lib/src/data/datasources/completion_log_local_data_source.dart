import 'package:isar/isar.dart';

import '../../domain/entities/completion_log.dart';
import '../models/isar_completion_log.dart';

abstract class CompletionLogLocalDataSource {
  Future<List<CompletionLog>> fetchCompletionLogs();
  Future<void> addCompletionLog(CompletionLog log);
}

class CompletionLogLocalDataSourceImpl implements CompletionLogLocalDataSource {
  final Isar isar;

  CompletionLogLocalDataSourceImpl({required this.isar});

  @override
  Future<void> addCompletionLog(CompletionLog log) async {
    final entity = IsarCompletionLog.fromCompletionLog(log);
    await isar.writeTxn(() => isar.isarCompletionLogs.put(entity));
  }

  @override
  Future<List<CompletionLog>> fetchCompletionLogs() async {
    final entities = await isar.isarCompletionLogs.where().findAll();
    entities.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return entities.map((entry) => entry.toCompletionLog()).toList();
  }
}
