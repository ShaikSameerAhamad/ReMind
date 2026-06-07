enum SyncOperationType { savedItemUpsert }

enum SyncOperationStatus { pending, failed, synced }

final class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.entityId,
    required this.ownerId,
    required this.type,
    required this.status,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    this.attemptCount = 0,
    this.lastError,
  });

  final String id;
  final String entityId;
  final String ownerId;
  final SyncOperationType type;
  final SyncOperationStatus status;
  final Map<String, Object?> payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attemptCount;
  final String? lastError;

  SyncOperation copyWith({
    SyncOperationStatus? status,
    DateTime? updatedAt,
    int? attemptCount,
    String? lastError,
  }) {
    return SyncOperation(
      id: id,
      entityId: entityId,
      ownerId: ownerId,
      type: type,
      status: status ?? this.status,
      payload: payload,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
