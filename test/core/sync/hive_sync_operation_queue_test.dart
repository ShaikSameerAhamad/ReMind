import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:remind/core/sync/hive_sync_operation_queue.dart';
import 'package:remind/core/sync/sync_operation.dart';

void main() {
  late Box<Map> box;
  late HiveSyncOperationQueue queue;

  setUp(() async {
    Hive.init('build/test_sync_hive_${DateTime.now().microsecondsSinceEpoch}');
    box = await Hive.openBox<Map>('sync_operations');
    queue = HiveSyncOperationQueue(box: box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
  });

  test('pendingOperations returns pending operations ordered by creation time', () async {
    await queue.enqueue(operation(id: 'newer', createdAt: DateTime.utc(2026, 6, 7, 12)));
    await queue.enqueue(operation(id: 'older', createdAt: DateTime.utc(2026, 6, 7, 10)));
    await queue.enqueue(operation(id: 'failed', status: SyncOperationStatus.failed));

    final pending = await queue.pendingOperations();

    expect(pending.map((operation) => operation.id), ['older', 'newer']);
  });

  test('markFailed increments attempts and stores sanitized error message', () async {
    await queue.enqueue(operation(id: 'op-1'));

    await queue.markFailed(id: 'op-1', error: 'token=secret permission-denied');
    final pending = await queue.pendingOperations();

    expect(pending.single.status, SyncOperationStatus.pending);
    expect(pending.single.attemptCount, 1);
    expect(pending.single.lastError, 'permission-denied');
  });

  test('markSynced removes operation from pending queue', () async {
    await queue.enqueue(operation(id: 'op-1'));

    await queue.markSynced(id: 'op-1');

    expect(await queue.pendingOperations(), isEmpty);
  });
}

SyncOperation operation({
  required String id,
  DateTime? createdAt,
  SyncOperationStatus status = SyncOperationStatus.pending,
}) {
  final timestamp = createdAt ?? DateTime.utc(2026, 6, 7, 10);
  return SyncOperation(
    id: id,
    entityId: 'item-$id',
    ownerId: 'guest-device',
    type: SyncOperationType.savedItemUpsert,
    status: status,
    payload: const {'url': 'https://example.com'},
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
