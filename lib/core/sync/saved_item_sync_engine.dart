import '../../features/queue/domain/saved_item.dart';
import '../../features/save/domain/saved_item_codec.dart';
import '../../features/save/domain/saved_item_repository.dart';
import 'saved_item_remote_store.dart';
import 'sync_operation.dart';
import 'sync_operation_queue.dart';

final class SyncDrainResult {
  const SyncDrainResult({
    required this.attempted,
    required this.synced,
    required this.failed,
  });

  final int attempted;
  final int synced;
  final int failed;

  @override
  bool operator ==(Object other) {
    return other is SyncDrainResult &&
        other.attempted == attempted &&
        other.synced == synced &&
        other.failed == failed;
  }

  @override
  int get hashCode => Object.hash(attempted, synced, failed);
}

final class SavedItemSyncEngine {
  const SavedItemSyncEngine({
    required SyncOperationQueue queue,
    required SavedItemRemoteStore remoteStore,
    required SavedItemRepository localRepository,
  })  : _queue = queue,
        _remoteStore = remoteStore,
        _localRepository = localRepository;

  final SyncOperationQueue _queue;
  final SavedItemRemoteStore _remoteStore;
  final SavedItemRepository _localRepository;

  Future<SyncDrainResult> drain() async {
    final operations = await _queue.pendingOperations();
    var synced = 0;
    var failed = 0;

    for (final operation in operations) {
      switch (operation.type) {
        case SyncOperationType.savedItemUpsert:
          final didSync = await _syncSavedItemUpsert(operation);
          if (didSync) {
            synced += 1;
          } else {
            failed += 1;
          }
      }
    }

    return SyncDrainResult(
      attempted: operations.length,
      synced: synced,
      failed: failed,
    );
  }

  Future<bool> _syncSavedItemUpsert(SyncOperation operation) async {
    try {
      final pendingItem = SavedItemCodec.fromJson(operation.payload);
      final syncedItem = pendingItem.copyWith(syncStatus: SyncStatus.synced);
      await _remoteStore.upsertSavedItem(syncedItem);
      await _localRepository.save(syncedItem);
      await _queue.markSynced(id: operation.id);
      return true;
    } catch (error) {
      await _queue.markFailed(id: operation.id, error: error.toString());
      await _markLocalItemFailedIfPayloadIsReadable(operation);
      return false;
    }
  }

  Future<void> _markLocalItemFailedIfPayloadIsReadable(SyncOperation operation) async {
    try {
      final failedItem = SavedItemCodec.fromJson(operation.payload).copyWith(syncStatus: SyncStatus.failed);
      await _localRepository.save(failedItem);
    } on FormatException {
      return;
    }
  }
}
