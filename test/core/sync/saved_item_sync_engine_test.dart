import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/sync/saved_item_remote_store.dart';
import 'package:remind/core/sync/saved_item_sync_engine.dart';
import 'package:remind/core/sync/sync_operation.dart';
import 'package:remind/core/sync/sync_operation_queue.dart';
import 'package:remind/features/queue/domain/saved_item.dart';
import 'package:remind/features/save/domain/saved_item_codec.dart';
import 'package:remind/features/save/domain/saved_item_repository.dart';

void main() {
  test('drain syncs pending saved item upserts and clears queue entries', () async {
    final item = _item(id: 'item-1', ownerId: 'uid-1', syncStatus: SyncStatus.pending);
    final queue = _RecordingSyncOperationQueue([
      _operation(id: 'op-1', item: item),
    ]);
    final remoteStore = _RecordingRemoteStore();
    final repository = _RecordingSavedItemRepository();
    final engine = SavedItemSyncEngine(
      queue: queue,
      remoteStore: remoteStore,
      localRepository: repository,
    );

    final result = await engine.drain();

    expect(result, const SyncDrainResult(attempted: 1, synced: 1, failed: 0));
    expect(remoteStore.upserts.single.id, 'item-1');
    expect(remoteStore.upserts.single.syncStatus, SyncStatus.synced);
    expect(repository.saved.single.syncStatus, SyncStatus.synced);
    expect(queue.syncedIds, ['op-1']);
    expect(queue.failedIds, isEmpty);
  });

  test('drain records failure and continues with later operations', () async {
    final first = _item(id: 'item-fails', ownerId: 'uid-1', syncStatus: SyncStatus.pending);
    final second = _item(id: 'item-syncs', ownerId: 'uid-1', syncStatus: SyncStatus.pending);
    final queue = _RecordingSyncOperationQueue([
      _operation(id: 'op-fails', item: first),
      _operation(id: 'op-syncs', item: second),
    ]);
    final remoteStore = _RecordingRemoteStore(failingIds: {'item-fails'});
    final repository = _RecordingSavedItemRepository();
    final engine = SavedItemSyncEngine(
      queue: queue,
      remoteStore: remoteStore,
      localRepository: repository,
    );

    final result = await engine.drain();

    expect(result, const SyncDrainResult(attempted: 2, synced: 1, failed: 1));
    expect(remoteStore.upserts.map((item) => item.id), ['item-fails', 'item-syncs']);
    expect(repository.saved.map((item) => item.syncStatus), [SyncStatus.failed, SyncStatus.synced]);
    expect(queue.failedIds, ['op-fails']);
    expect(queue.syncedIds, ['op-syncs']);
  });

  test('drain marks invalid saved item payload as failed without remote write', () async {
    final queue = _RecordingSyncOperationQueue([
      SyncOperation(
        id: 'op-invalid',
        entityId: 'item-invalid',
        ownerId: 'uid-1',
        type: SyncOperationType.savedItemUpsert,
        status: SyncOperationStatus.pending,
        payload: const {'id': 'item-invalid'},
        createdAt: DateTime.utc(2026, 6, 7),
        updatedAt: DateTime.utc(2026, 6, 7),
      ),
    ]);
    final remoteStore = _RecordingRemoteStore();
    final repository = _RecordingSavedItemRepository();
    final engine = SavedItemSyncEngine(
      queue: queue,
      remoteStore: remoteStore,
      localRepository: repository,
    );

    final result = await engine.drain();

    expect(result, const SyncDrainResult(attempted: 1, synced: 0, failed: 1));
    expect(remoteStore.upserts, isEmpty);
    expect(repository.saved, isEmpty);
    expect(queue.failedIds, ['op-invalid']);
    expect(queue.failureMessages.single, contains('Saved item field'));
  });
}

SavedItem _item({
  required String id,
  required String ownerId,
  required SyncStatus syncStatus,
}) {
  return SavedItem(
    id: id,
    ownerId: ownerId,
    title: 'Article $id',
    url: 'https://example.com/$id',
    category: ItemCategory.article,
    sourceDomain: 'example.com',
    savedAt: DateTime.utc(2026, 6, 7, 10),
    updatedAt: DateTime.utc(2026, 6, 7, 10),
    syncStatus: syncStatus,
  );
}

SyncOperation _operation({required String id, required SavedItem item}) {
  return SyncOperation(
    id: id,
    entityId: item.id,
    ownerId: item.ownerId,
    type: SyncOperationType.savedItemUpsert,
    status: SyncOperationStatus.pending,
    payload: SavedItemCodec.toJson(item),
    createdAt: item.savedAt,
    updatedAt: item.updatedAt,
  );
}

final class _RecordingSyncOperationQueue implements SyncOperationQueue {
  _RecordingSyncOperationQueue(this.operations);

  final List<SyncOperation> operations;
  final syncedIds = <String>[];
  final failedIds = <String>[];
  final failureMessages = <String>[];

  @override
  Future<void> enqueue(SyncOperation operation) async {
    operations.add(operation);
  }

  @override
  Future<void> markFailed({required String id, required String error}) async {
    failedIds.add(id);
    failureMessages.add(error);
  }

  @override
  Future<void> markSynced({required String id}) async {
    syncedIds.add(id);
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async => operations;
}

final class _RecordingRemoteStore implements SavedItemRemoteStore {
  _RecordingRemoteStore({this.failingIds = const {}});

  final Set<String> failingIds;
  final upserts = <SavedItem>[];

  @override
  Future<void> upsertSavedItem(SavedItem item) async {
    upserts.add(item);
    if (failingIds.contains(item.id)) {
      throw StateError('network unavailable for ${item.id}');
    }
  }
}

final class _RecordingSavedItemRepository implements SavedItemRepository {
  final saved = <SavedItem>[];

  @override
  Future<void> save(SavedItem item) async {
    saved.add(item);
  }

  @override
  Stream<List<SavedItem>> watchItems({required String ownerId}) {
    return Stream.value(saved.where((item) => item.ownerId == ownerId).toList());
  }
}
