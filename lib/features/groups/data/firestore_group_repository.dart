import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/accept_group_invite.dart';
import '../domain/group_models.dart';
import '../domain/group_repository.dart';

final class FirestoreGroupRepository implements GroupRepository {
  const FirestoreGroupRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

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

  @override
  Future<void> createInvite(GroupInvite invite) {
    return _firestore.collection('groups').doc(invite.groupId).set(
      {
        'inviteCodes': {
          invite.code: {
            'code': invite.code,
            'deepLink': invite.deepLink,
            'createdBy': invite.createdBy,
            'recipientEmail': invite.recipientEmail,
            'createdAt': Timestamp.fromDate(invite.createdAt),
            'expiresAt': Timestamp.fromDate(invite.expiresAt),
            'status': 'active',
          },
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {
    final groupRef = _firestore.collection('groups').doc(acceptance.groupId);
    final userRef =
        _firestore.collection('users').doc(acceptance.member.userId);
    await _firestore.runTransaction((transaction) async {
      final groupSnapshot = await transaction.get(groupRef);
      final groupData = groupSnapshot.data();
      final invite = _inviteData(groupData, acceptance.inviteCode);
      if (!groupSnapshot.exists || invite == null) {
        throw const GroupInviteAcceptanceException(
            'Invite link is no longer active.');
      }
      if (invite['status'] != 'active') {
        throw const GroupInviteAcceptanceException(
            'Invite has already been used.');
      }

      final expiresAt = invite['expiresAt'];
      if (expiresAt is Timestamp &&
          expiresAt.toDate().isBefore(acceptance.acceptedAt)) {
        throw const GroupInviteAcceptanceException('Invite has expired.');
      }

      transaction.set(
        groupRef,
        {
          'members': {
            acceptance.member.userId: _membershipToFirestore(acceptance.member),
          },
          'inviteCodes': {
            acceptance.inviteCode: {
              'status': 'accepted',
              'acceptedBy': acceptance.member.userId,
              'acceptedAt': Timestamp.fromDate(acceptance.acceptedAt),
            },
          },
          'updatedAt': FieldValue.serverTimestamp(),
          'lastActivityAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      transaction.set(
        userRef,
        {
          'groups': FieldValue.arrayUnion([acceptance.groupId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Map<String, Object?> _toFirestore(Group group) {
    return {
      'name': group.name,
      'createdBy': group.createdBy,
      'members': {
        for (final member in group.members)
          member.userId: {
            ..._membershipToFirestore(member),
          },
      },
      'inviteCodes': const <String, Object?>{},
      'createdAt': Timestamp.fromDate(group.createdAt),
      'updatedAt': Timestamp.fromDate(group.updatedAt),
      'lastActivityAt': Timestamp.fromDate(group.lastActivityAt),
      'archivedAt': group.archivedAt == null
          ? null
          : Timestamp.fromDate(group.archivedAt!),
    };
  }

  Map<String, Object?>? _inviteData(
      Map<String, Object?>? groupData, String inviteCode) {
    final inviteCodes = groupData?['inviteCodes'];
    if (inviteCodes is! Map) {
      return null;
    }
    final invite = inviteCodes[inviteCode];
    if (invite is! Map) {
      return null;
    }
    return invite.cast<String, Object?>();
  }

  Map<String, Object?> _membershipToFirestore(GroupMembership member) {
    return {
      'role': member.role.name,
      'joinedAt': Timestamp.fromDate(member.joinedAt),
      'displayName': member.displayName,
      'avatarUrl': member.avatarUrl,
    };
  }
}
