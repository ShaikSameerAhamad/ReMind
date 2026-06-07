import 'sync_operation.dart';

abstract interface class SyncOperationQueue {
  Future<void> enqueue(SyncOperation operation);

  Future<List<SyncOperation>> pendingOperations();

  Future<void> markFailed({required String id, required String error});

  Future<void> markSynced({required String id});
}
