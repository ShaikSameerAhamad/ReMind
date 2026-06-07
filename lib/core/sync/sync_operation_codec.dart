import 'sync_operation.dart';

abstract final class SyncOperationCodec {
  static Map<String, Object?> toJson(SyncOperation operation) {
    return {
      'id': operation.id,
      'entityId': operation.entityId,
      'ownerId': operation.ownerId,
      'type': operation.type.name,
      'status': operation.status.name,
      'payload': operation.payload,
      'createdAt': operation.createdAt.toIso8601String(),
      'updatedAt': operation.updatedAt.toIso8601String(),
      'attemptCount': operation.attemptCount,
      'lastError': operation.lastError,
    };
  }

  static SyncOperation fromJson(Map<dynamic, dynamic> json) {
    return SyncOperation(
      id: json.requireString('id'),
      entityId: json.requireString('entityId'),
      ownerId: json.requireString('ownerId'),
      type: SyncOperationType.values.byName(json.requireString('type')),
      status: SyncOperationStatus.values.byName(json.requireString('status')),
      payload: json.optionalMap('payload'),
      createdAt: DateTime.parse(json.requireString('createdAt')),
      updatedAt: DateTime.parse(json.requireString('updatedAt')),
      attemptCount: json.optionalInt('attemptCount') ?? 0,
      lastError: json.optionalString('lastError'),
    );
  }
}

extension _SyncOperationJson on Map<dynamic, dynamic> {
  String requireString(String key) {
    final value = this[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('Sync operation field "$key" is required.');
  }

  String? optionalString(String key) {
    final value = this[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  int? optionalInt(String key) {
    final value = this[key];
    return value is int ? value : null;
  }

  Map<String, Object?> optionalMap(String key) {
    final value = this[key];
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value as Object?));
    }
    return const {};
  }
}
