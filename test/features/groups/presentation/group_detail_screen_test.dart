import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/alarms/domain/alarm_repository.dart';
import 'package:remind/features/alarms/domain/shared_alarm.dart';
import 'package:remind/features/alarms/presentation/alarm_providers.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';
import 'package:remind/features/groups/presentation/group_detail_screen.dart';
import 'package:remind/features/groups/presentation/group_providers.dart';
import 'package:remind/features/tasks/domain/group_task.dart';
import 'package:remind/features/tasks/domain/task_repository.dart';
import 'package:remind/features/tasks/presentation/task_providers.dart';

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
    final taskRepository = _RecordingTaskRepository();
    final alarmRepository = _RecordingAlarmRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmRepositoryProvider.overrideWithValue(alarmRepository),
          authRepositoryProvider.overrideWithValue(authRepository),
          groupRepositoryProvider.overrideWithValue(groupRepository),
          taskRepositoryProvider.overrideWithValue(taskRepository),
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

  testWidgets('signed-in user creates task assigned to group member',
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
    final taskRepository = _RecordingTaskRepository();
    final alarmRepository = _RecordingAlarmRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmRepositoryProvider.overrideWithValue(alarmRepository),
          authRepositoryProvider.overrideWithValue(authRepository),
          groupRepositoryProvider.overrideWithValue(groupRepository),
          taskRepositoryProvider.overrideWithValue(taskRepository),
        ],
        child: const MaterialApp(home: GroupDetailScreen(groupId: 'family')),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Create task').first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'Buy milk');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Notes'), 'Use the shared card');
    await tester.tap(find.text('Unassigned'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aisha').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create task').last);
    await tester.pumpAndSettle();

    expect(taskRepository.createdTasks.single.title, 'Buy milk');
    expect(taskRepository.createdTasks.single.assignedTo, 'uid-2');
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Aisha'), findsOneWidget);
  });

  testWidgets('signed-in user creates shared alarm for group member',
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
    final taskRepository = _RecordingTaskRepository();
    final alarmRepository = _RecordingAlarmRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmRepositoryProvider.overrideWithValue(alarmRepository),
          authRepositoryProvider.overrideWithValue(authRepository),
          groupRepositoryProvider.overrideWithValue(groupRepository),
          taskRepositoryProvider.overrideWithValue(taskRepository),
        ],
        child: const MaterialApp(home: GroupDetailScreen(groupId: 'family')),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Create alarm'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'Medicine');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Message'), 'Take after food');
    await tester.tap(find.text('Aisha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create alarm').last);
    await tester.pumpAndSettle();

    expect(alarmRepository.createdAlarms.single.title, 'Medicine');
    expect(alarmRepository.createdAlarms.single.recipients, ['uid-2']);
    expect(find.text('Medicine'), findsOneWidget);
    expect(find.text('Once'), findsOneWidget);
  });
}

final class _RecordingGroupRepository implements GroupRepository {
  final invites = <GroupInvite>[];
  final group = Group(
    id: 'family',
    name: 'Family',
    createdBy: 'uid-1',
    createdAt: DateTime.utc(2026, 6, 7),
    updatedAt: DateTime.utc(2026, 6, 7),
    lastActivityAt: DateTime.utc(2026, 6, 7),
    members: [
      GroupMembership(
        userId: 'uid-1',
        displayName: 'Sameer',
        role: GroupRole.admin,
        joinedAt: DateTime.utc(2026, 6, 7),
      ),
      GroupMembership(
        userId: 'uid-2',
        displayName: 'Aisha',
        role: GroupRole.member,
        joinedAt: DateTime.utc(2026, 6, 7),
      ),
    ],
  );

  @override
  Stream<Group?> watchGroup(String groupId) => Stream.value(group);

  @override
  Future<void> createGroup(Group group) async {}

  @override
  Future<void> createInvite(GroupInvite invite) async {
    invites.add(invite);
  }

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {}
}

final class _RecordingAlarmRepository implements AlarmRepository {
  final createdAlarms = <SharedAlarm>[];
  final _alarms = <SharedAlarm>[];
  final _controller = StreamController<List<SharedAlarm>>.broadcast();

  @override
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId) async* {
    yield _alarms;
    yield* _controller.stream;
  }

  @override
  Stream<SharedAlarm?> watchAlarm({
    required String groupId,
    required String alarmId,
  }) {
    return Stream.value(_alarmById(alarmId));
  }

  @override
  Future<void> createAlarm(SharedAlarm alarm) async {
    createdAlarms.add(alarm);
    _alarms.add(alarm);
    _controller.add(List.unmodifiable(_alarms));
  }

  @override
  Future<void> dismissAlarm(AlarmDismissal dismissal) async {}

  SharedAlarm? _alarmById(String alarmId) {
    for (final alarm in _alarms) {
      if (alarm.id == alarmId) {
        return alarm;
      }
    }
    return null;
  }
}

final class _RecordingTaskRepository implements TaskRepository {
  final createdTasks = <GroupTask>[];
  final _tasks = <GroupTask>[];
  final _controller = StreamController<List<GroupTask>>.broadcast();

  @override
  Stream<List<GroupTask>> watchGroupTasks(String groupId) async* {
    yield _tasks;
    yield* _controller.stream;
  }

  @override
  Stream<GroupTask?> watchTask(
      {required String groupId, required String taskId}) {
    return Stream.value(_taskById(taskId));
  }

  @override
  Future<void> createTask(GroupTask task) async {
    createdTasks.add(task);
    _tasks.add(task);
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Future<void> completeTask(GroupTaskCompletion completion) async {}

  @override
  Future<void> addComment(TaskComment comment) async {}

  GroupTask? _taskById(String taskId) {
    for (final task in _tasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }
}
