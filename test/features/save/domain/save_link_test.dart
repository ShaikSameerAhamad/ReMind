import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/sync/sync_operation.dart';
import 'package:remind/core/sync/sync_operation_queue.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/queue/domain/saved_item.dart';
import 'package:remind/features/save/domain/save_link.dart';
import 'package:remind/features/save/domain/saved_item_repository.dart';

void main() {
  test('saveLink rejects insecure URLs before writing', () async {
    final repository = _RecordingRepository();
    final useCase = SaveLink(repository: repository, now: () => DateTime.utc(2026, 6, 7));

    final result = await useCase(
      ownerId: 'guest-device',
      url: 'http://example.com/article',
      title: '',
    );

    expect(result, const SaveLinkFailure(Invalid('Use a secure https link.')));
    expect(repository.savedItems, isEmpty);
  });

  test('saveLink persists a local saved item with source domain and title fallback', () async {
    final repository = _RecordingRepository();
    final useCase = SaveLink(repository: repository, now: () => DateTime.utc(2026, 6, 7, 10));

    final result = await useCase(
      ownerId: 'guest-device',
      url: 'https://example.com/articles/offline-first',
      title: '',
    );

    expect(result, isA<SaveLinkSuccess>());
    expect(repository.savedItems.single.ownerId, 'guest-device');
    expect(repository.savedItems.single.url, 'https://example.com/articles/offline-first');
    expect(repository.savedItems.single.title, 'example.com');
    expect(repository.savedItems.single.sourceDomain, 'example.com');
    expect(repository.savedItems.single.category, ItemCategory.article);
    expect(repository.savedItems.single.syncStatus, SyncStatus.synced);
  });

  test('saveLink can enqueue a signed-in saved item for cloud sync', () async {
    final repository = _RecordingRepository();
    final syncQueue = _RecordingSyncQueue();
    final useCase = SaveLink(
      repository: repository,
      syncQueue: syncQueue,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      ownerId: 'user-123',
      url: 'https://remind.app/docs/offline-first',
      title: 'Offline-first architecture',
      shouldSyncToCloud: true,
    );

    expect(result, isA<SaveLinkSuccess>());
    expect(repository.savedItems.single.syncStatus, SyncStatus.pending);
    expect(syncQueue.enqueued.single.type, SyncOperationType.savedItemUpsert);
    expect(syncQueue.enqueued.single.ownerId, 'user-123');
    expect(syncQueue.enqueued.single.entityId, repository.savedItems.single.id);
    expect(syncQueue.enqueued.single.status, SyncOperationStatus.pending);
    expect(syncQueue.enqueued.single.payload['title'], 'Offline-first architecture');
    expect(syncQueue.enqueued.single.payload['syncStatus'], SyncStatus.pending.name);
  });
}

final class _RecordingRepository implements SavedItemRepository {
  final savedItems = <SavedItem>[];

  @override
  Future<void> save(SavedItem item) async {
    savedItems.add(item);
  }

  @override
  Stream<List<SavedItem>> watchItems({required String ownerId}) {
    return Stream.value(savedItems.where((item) => item.ownerId == ownerId).toList());
  }
}

final class _RecordingSyncQueue implements SyncOperationQueue {
  final enqueued = <SyncOperation>[];

  @override
  Future<void> enqueue(SyncOperation operation) async {
    enqueued.add(operation);
  }

  @override
  Future<void> markFailed({required String id, required String error}) async {}

  @override
  Future<void> markSynced({required String id}) async {}

  @override
  Future<List<SyncOperation>> pendingOperations() async => enqueued;
}
