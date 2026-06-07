import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/app.dart';
import 'package:remind/features/alarms/domain/alarm_repository.dart';
import 'package:remind/features/alarms/domain/shared_alarm.dart';
import 'package:remind/features/alarms/presentation/alarm_providers.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';
import 'package:remind/features/groups/presentation/group_providers.dart';
import 'package:remind/features/tasks/domain/group_task.dart';
import 'package:remind/features/tasks/domain/task_repository.dart';
import 'package:remind/features/tasks/presentation/task_providers.dart';

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
          alarmRepositoryProvider.overrideWithValue(_EmptyAlarmRepository()),
          groupRepositoryProvider
              .overrideWithValue(_RecordingGroupRepository()),
          taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
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
          alarmRepositoryProvider.overrideWithValue(_EmptyAlarmRepository()),
          groupRepositoryProvider.overrideWithValue(groupRepository),
          taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
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
  Stream<Group?> watchGroup(String groupId) => const Stream.empty();

  @override
  Future<void> createGroup(Group group) async {
    created.add(group);
  }

  @override
  Future<void> createInvite(GroupInvite invite) async {}

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {}
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

  @override
  Future<void> addComment(TaskComment comment) async {}
}

final class _EmptyAlarmRepository implements AlarmRepository {
  @override
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId) =>
      Stream.value(const []);

  @override
  Stream<SharedAlarm?> watchAlarm({
    required String groupId,
    required String alarmId,
  }) =>
      Stream.value(null);

  @override
  Future<void> createAlarm(SharedAlarm alarm) async {}

  @override
  Future<void> dismissAlarm(AlarmDismissal dismissal) async {}
}
