import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/group_models.dart';
import '../domain/group_repository.dart';

final class FirestoreGroupRepository implements GroupRepository {
  const FirestoreGroupRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> createGroup(Group group) async {
    final batch = _firestore.batch();
    final groupRef = _firestore.collection('groups').doc(group.id);
    batch.set(groupRef, _toFirestore(group), SetOptions(merge: true));
    batch.set(
      _firestore.collection('users').doc(group.createdBy),
      {
        'groups': FieldValue.arrayUnion([group.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Map<String, Object?> _toFirestore(Group group) {
    return {
      'name': group.name,
      'createdBy': group.createdBy,
      'members': {
        for (final member in group.members)
          member.userId: {
            'role': member.role.name,
            'joinedAt': Timestamp.fromDate(member.joinedAt),
            'displayName': member.displayName,
            'avatarUrl': member.avatarUrl,
          },
      },
      'inviteCodes': const <String, Object?>{},
      'createdAt': Timestamp.fromDate(group.createdAt),
      'updatedAt': Timestamp.fromDate(group.updatedAt),
      'lastActivityAt': Timestamp.fromDate(group.lastActivityAt),
      'archivedAt': group.archivedAt == null ? null : Timestamp.fromDate(group.archivedAt!),
    };
  }
}
