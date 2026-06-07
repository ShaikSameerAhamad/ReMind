import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/sync/saved_item_remote_store.dart';
import '../../queue/domain/saved_item.dart';

final class FirestoreSavedItemRemoteStore implements SavedItemRemoteStore {
  const FirestoreSavedItemRemoteStore({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> upsertSavedItem(SavedItem item) {
    return _firestore
        .collection('users')
        .doc(item.ownerId)
        .collection('items')
        .doc(item.id)
        .set(_toFirestore(item), SetOptions(merge: true));
  }

  Map<String, Object?> _toFirestore(SavedItem item) {
    return {
      'id': item.id,
      'ownerId': item.ownerId,
      'title': item.title,
      'url': item.url,
      'category': item.category.name,
      'sourceDomain': item.sourceDomain,
      'thumbnailUrl': item.thumbnailUrl,
      'readTimeMinutes': item.readTimeMinutes,
      'savedAt': Timestamp.fromDate(item.savedAt),
      'updatedAt': Timestamp.fromDate(item.updatedAt),
      'reminderAt': item.reminderAt == null ? null : Timestamp.fromDate(item.reminderAt!),
      'isCompleted': item.isCompleted,
      'isArchived': item.isArchived,
      'readingProgress': item.readingProgress,
      'lastOpenedAt': item.lastOpenedAt == null ? null : Timestamp.fromDate(item.lastOpenedAt!),
      'tags': item.tags,
      'syncStatus': item.syncStatus.name,
      'serverUpdatedAt': FieldValue.serverTimestamp(),
    };
  }
}
