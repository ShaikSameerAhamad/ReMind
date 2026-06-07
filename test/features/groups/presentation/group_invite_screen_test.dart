import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:remind/core/routing/app_routes.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';
import 'package:remind/features/groups/presentation/group_detail_screen.dart';
import 'package:remind/features/groups/presentation/group_invite_screen.dart';
import 'package:remind/features/groups/presentation/group_providers.dart';
import 'package:remind/features/tasks/domain/group_task.dart';
import 'package:remind/features/tasks/domain/task_repository.dart';
import 'package:remind/features/tasks/presentation/task_providers.dart';

import '../../../support/recording_auth_repository.dart';

void main() {
  testWidgets('signed-in user accepts group invite and opens group detail',
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
          taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: AppRoutes.groupInvite('family', 'INV123'),
            routes: [
              GoRoute(
                path: AppRoutes.groupInvitePattern,
                builder: (context, state) => GroupInviteScreen(
                  groupId: state.pathParameters['groupId']!,
                  inviteCode: state.pathParameters['inviteCode']!,
                ),
              ),
              GoRoute(
                path: AppRoutes.groupDetailPattern,
                builder: (context, state) => GroupDetailScreen(
                  groupId: state.pathParameters['groupId']!,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept invite'));
    await tester.pumpAndSettle();

    expect(groupRepository.acceptances.single.groupId, 'family');
    expect(groupRepository.acceptances.single.inviteCode, 'INV123');
    expect(find.text('Shared tasks'), findsOneWidget);
  });

  testWidgets('guest user is routed to sign in before accepting invite',
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
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: AppRoutes.groupInvite('family', 'INV123'),
            routes: [
              GoRoute(
                path: AppRoutes.auth,
                builder: (context, state) =>
                    const Scaffold(body: Text('Sign in screen')),
              ),
              GoRoute(
                path: AppRoutes.groupInvitePattern,
                builder: (context, state) => GroupInviteScreen(
                  groupId: state.pathParameters['groupId']!,
                  inviteCode: state.pathParameters['inviteCode']!,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in to continue'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in screen'), findsOneWidget);
  });
}

final class _RecordingGroupRepository implements GroupRepository {
  final acceptances = <GroupInviteAcceptance>[];

  @override
  Stream<Group?> watchGroup(String groupId) => Stream.value(
        Group(
          id: groupId,
          name: 'Family',
          createdBy: 'uid-1',
          createdAt: DateTime.utc(2026, 6, 7),
          updatedAt: DateTime.utc(2026, 6, 7),
          lastActivityAt: DateTime.utc(2026, 6, 7),
          members: const [],
        ),
      );

  @override
  Future<void> createGroup(Group group) async {}

  @override
  Future<void> createInvite(GroupInvite invite) async {}

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {
    acceptances.add(acceptance);
  }
}

final class _EmptyTaskRepository implements TaskRepository {
  @override
  Stream<List<GroupTask>> watchGroupTasks(String groupId) =>
      Stream.value(const []);

  @override
  Stream<GroupTask?> watchTask(
          {required String groupId, required String taskId}) =>
      Stream.value(null);

  @override
  Future<void> createTask(GroupTask task) async {}

  @override
  Future<void> completeTask(GroupTaskCompletion completion) async {}
}
