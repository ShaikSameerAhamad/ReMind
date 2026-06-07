import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/groups/domain/create_group_invite.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';

void main() {
  test('createGroupInvite rejects guests before writing', () async {
    final repository = _RecordingGroupRepository();
    final useCase = CreateGroupInvite(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      codeGenerator: () => 'INV123',
    );

    final result = await useCase(
      session: AuthSession.guest(deviceId: 'device-1'),
      groupId: 'family',
      recipientEmail: null,
    );

    expect(
        result,
        const CreateGroupInviteFailure(
            Invalid('Sign in to invite group members.')));
    expect(repository.invites, isEmpty);
  });

  test('createGroupInvite validates group id before writing', () async {
    final repository = _RecordingGroupRepository();
    final useCase = CreateGroupInvite(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      codeGenerator: () => 'INV123',
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: '',
      recipientEmail: null,
    );

    expect(
        result, const CreateGroupInviteFailure(Invalid('Group is required.')));
    expect(repository.invites, isEmpty);
  });

  test('createGroupInvite writes invite metadata with shareable link',
      () async {
    final repository = _RecordingGroupRepository();
    final useCase = CreateGroupInvite(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      codeGenerator: () => 'INV123',
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      recipientEmail: ' friend@example.com ',
    );

    expect(result, isA<CreateGroupInviteSuccess>());
    final invite = repository.invites.single;
    expect(invite.groupId, 'family');
    expect(invite.code, 'INV123');
    expect(invite.createdBy, 'uid-1');
    expect(invite.recipientEmail, 'friend@example.com');
    expect(invite.deepLink, 'remind://groups/family/invites/INV123');
    expect(invite.expiresAt, DateTime.utc(2026, 6, 14, 10));
  });
}

AuthSession _signedInSession() {
  return AuthSession.signedIn(
    profile: const AuthProfile(
      uid: 'uid-1',
      email: 'sameer@example.com',
      displayName: 'Sameer',
      avatarUrl: null,
    ),
  );
}

final class _RecordingGroupRepository implements GroupRepository {
  final invites = <GroupInvite>[];

  @override
  Stream<Group?> watchGroup(String groupId) => const Stream.empty();

  @override
  Future<void> createGroup(Group group) async {}

  @override
  Future<void> createInvite(GroupInvite invite) async {
    invites.add(invite);
  }

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {}
}
