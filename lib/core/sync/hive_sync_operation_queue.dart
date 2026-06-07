import 'package:hive_ce/hive.dart';

import 'sync_operation.dart';
import 'sync_operation_codec.dart';
import 'sync_operation_queue.dart';

final class HiveSyncOperationQueue implements SyncOperationQueue {
  HiveSyncOperationQueue({required Box<Map> box}) : _box = box;

  final Box<Map> _box;

  @override
  Future<void> enqueue(SyncOperation operation) {
    return _box.put(operation.id, SyncOperationCodec.toJson(operation));
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async {
    final operations = _box.values
        .map(SyncOperationCodec.fromJson)
        .where((operation) => operation.status == SyncOperationStatus.pending)
        .toList();
    operations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return operations;
  }

  @override
  Future<void> markFailed({required String id, required String error}) async {
    final operation = _operationFor(id);
    if (operation == null) {
      return;
    }
    await _box.put(
      id,
      SyncOperationCodec.toJson(
        operation.copyWith(
          status: SyncOperationStatus.pending,
          updatedAt: DateTime.now().toUtc(),
          attemptCount: operation.attemptCount + 1,
          lastError: _sanitizeError(error),
        ),
      ),
    );
  }

  @override
  Future<void> markSynced({required String id}) {
    return _box.delete(id);
  }

  SyncOperation? _operationFor(String id) {
    final value = _box.get(id);
    return value == null ? null : SyncOperationCodec.fromJson(value);
  }

  String _sanitizeError(String error) {
    return error
        .replaceAll(RegExp(r'token=[^\s]+'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
