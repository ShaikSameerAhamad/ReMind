import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';
import 'package:remind/features/groups/presentation/group_detail_screen.dart';
import 'package:remind/features/groups/presentation/group_providers.dart';

import '../../../support/recording_auth_repository.dart';

void main() {
  testWidgets('signed-in user creates invite from group detail screen',
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
        child: const MaterialApp(home: GroupDetailScreen(groupId: 'family')),
      ),
    );

    await tester.tap(find.text('Invite member'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'friend@example.com');
    await tester.tap(find.text('Create invite'));
    await tester.pumpAndSettle();

    expect(groupRepository.invites.single.groupId, 'family');
    expect(groupRepository.invites.single.recipientEmail, 'friend@example.com');
    expect(
        find.textContaining('remind://groups/family/invites/'), findsOneWidget);
  });
}

final class _RecordingGroupRepository implements GroupRepository {
  final invites = <GroupInvite>[];

  @override
  Future<void> createGroup(Group group) async {}

  @override
  Future<void> createInvite(GroupInvite invite) async {
    invites.add(invite);
  }

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {}
}
