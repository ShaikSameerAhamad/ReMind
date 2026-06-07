import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/app.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';
import 'package:remind/features/groups/presentation/group_providers.dart';

import '../../../support/recording_auth_repository.dart';

void main() {
  testWidgets('guest users see upgrade prompt instead of group creation',
      (tester) async {
    final authRepository = RecordingAuthRepository(
      initialSession: AuthSession.guest(deviceId: 'device-1'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          groupRepositoryProvider
              .overrideWithValue(_RecordingGroupRepository()),
        ],
        child: const ReMindApp(),
      ),
    );

    await tester.tap(find.text('Family Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to create groups'), findsOneWidget);
    expect(find.text('Create group'), findsNothing);
  });

  testWidgets('signed-in users can create a group from groups screen',
      (tester) async {
    final authRepository = RecordingAuthRepository(
      initialSession: AuthSession.signedIn(
        profile: const AuthProfile(
          uid: 'uid-1',
          email: 'sameer@example.com',
          displayName: 'Sameer',
          avatarUrl: null,
        ),
      ),
    );
    final groupRepository = _RecordingGroupRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          groupRepositoryProvider.overrideWithValue(groupRepository),
        ],
        child: const ReMindApp(),
      ),
    );

    await tester.tap(find.text('Family Tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Family Chores');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(groupRepository.created.single.name, 'Family Chores');
    expect(groupRepository.created.single.members.single.role, GroupRole.admin);
    expect(find.text('Family Chores created.'), findsOneWidget);
  });
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
