import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/sync/sync_operation.dart';
import 'package:remind/core/sync/sync_operation_codec.dart';

void main() {
  test('sync operation codec round trips all retry-critical fields', () {
    final operation = SyncOperation(
      id: 'op-1',
      entityId: 'item-1',
      ownerId: 'guest-device',
      type: SyncOperationType.savedItemUpsert,
      status: SyncOperationStatus.pending,
      payload: const {'title': 'Article', 'url': 'https://example.com'},
      createdAt: DateTime.utc(2026, 6, 7, 10),
      updatedAt: DateTime.utc(2026, 6, 7, 11),
      attemptCount: 2,
      lastError: 'permission-denied',
    );

    final encoded = SyncOperationCodec.toJson(operation);
    final decoded = SyncOperationCodec.fromJson(encoded);

    expect(decoded.id, operation.id);
    expect(decoded.entityId, operation.entityId);
    expect(decoded.ownerId, operation.ownerId);
    expect(decoded.type, operation.type);
    expect(decoded.status, operation.status);
    expect(decoded.payload, operation.payload);
    expect(decoded.createdAt, operation.createdAt);
    expect(decoded.updatedAt, operation.updatedAt);
    expect(decoded.attemptCount, operation.attemptCount);
    expect(decoded.lastError, operation.lastError);
  });
}
