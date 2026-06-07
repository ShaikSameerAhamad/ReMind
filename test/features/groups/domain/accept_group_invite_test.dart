import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/groups/domain/accept_group_invite.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';

void main() {
  test('acceptGroupInvite rejects guests before writing', () async {
    final repository = _RecordingGroupRepository();
    final useCase = AcceptGroupInvite(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: AuthSession.guest(deviceId: 'device-1'),
      groupId: 'family',
      inviteCode: 'INV123',
    );

    expect(result,
        const AcceptGroupInviteFailure(Invalid('Sign in to join this group.')));
    expect(repository.acceptances, isEmpty);
  });

  test('acceptGroupInvite validates invite route segments', () async {
    final repository = _RecordingGroupRepository();
    final useCase = AcceptGroupInvite(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family/private',
      inviteCode: 'INV123',
    );

    expect(result,
        const AcceptGroupInviteFailure(Invalid('Invite link is invalid.')));
    expect(repository.acceptances, isEmpty);
  });

  test('acceptGroupInvite records signed-in user as member', () async {
    final repository = _RecordingGroupRepository();
    final useCase = AcceptGroupInvite(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      inviteCode: 'INV123',
    );

    expect(result, isA<AcceptGroupInviteSuccess>());
    final acceptance = repository.acceptances.single;
    expect(acceptance.groupId, 'family');
    expect(acceptance.inviteCode, 'INV123');
    expect(acceptance.acceptedAt, DateTime.utc(2026, 6, 7, 10));
    expect(acceptance.member.userId, 'uid-1');
    expect(acceptance.member.displayName, 'Sameer');
    expect(acceptance.member.role, GroupRole.member);
  });

  test('acceptGroupInvite maps inactive invite errors to validation failures',
      () async {
    final repository = _RecordingGroupRepository()
      ..failure = const GroupInviteAcceptanceException('Invite has expired.');
    final useCase = AcceptGroupInvite(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      inviteCode: 'INV123',
    );

    expect(
        result, const AcceptGroupInviteFailure(Invalid('Invite has expired.')));
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
  final acceptances = <GroupInviteAcceptance>[];
  GroupInviteAcceptanceException? failure;

  @override
  Future<void> createGroup(Group group) async {}

  @override
  Future<void> createInvite(GroupInvite invite) async {}

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    acceptances.add(acceptance);
  }
}
