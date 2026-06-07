import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/groups/domain/create_group.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';

void main() {
  test('createGroup rejects guests before writing', () async {
    final repository = _RecordingGroupRepository();
    final useCase = CreateGroup(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'group-1',
    );

    final result = await useCase(
      session: AuthSession.guest(deviceId: 'device-1'),
      name: 'Family',
    );

    expect(result,
        const CreateGroupFailure(Invalid('Sign in to create shared groups.')));
    expect(repository.created, isEmpty);
  });

  test('createGroup validates group name before writing', () async {
    final repository = _RecordingGroupRepository();
    final useCase = CreateGroup(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'group-1',
    );

    final result = await useCase(
      session: _signedInSession(),
      name: '',
    );

    expect(
        result, const CreateGroupFailure(Invalid('Group name is required.')));
    expect(repository.created, isEmpty);
  });

  test('createGroup creates signed-in group with creator as admin', () async {
    final repository = _RecordingGroupRepository();
    final useCase = CreateGroup(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'group-1',
    );

    final result = await useCase(
      session: _signedInSession(),
      name: '  Family Chores  ',
    );

    expect(result, isA<CreateGroupSuccess>());
    final group = repository.created.single;
    expect(group.id, 'group-1');
    expect(group.name, 'Family Chores');
    expect(group.createdBy, 'uid-1');
    expect(group.members.single.userId, 'uid-1');
    expect(group.members.single.displayName, 'Sameer');
    expect(group.members.single.role, GroupRole.admin);
    expect(group.members.single.canManageMembers, isTrue);
  });
}

AuthSession _signedInSession() {
  return AuthSession.signedIn(
    profile: const AuthProfile(
      uid: 'uid-1',
      email: 'sameer@example.com',
      displayName: 'Sameer',
      avatarUrl: 'https://example.com/avatar.png',
    ),
  );
}

final class _RecordingGroupRepository implements GroupRepository {
  final created = <Group>[];

  @override
  Future<void> createGroup(Group group) async {
    created.add(group);
  }

  @override
  Future<void> createInvite(GroupInvite invite) async {}

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {}
}
