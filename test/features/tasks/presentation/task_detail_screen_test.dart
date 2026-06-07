import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';
import 'package:remind/features/groups/domain/group_models.dart';
import 'package:remind/features/groups/domain/group_repository.dart';
import 'package:remind/features/groups/presentation/group_providers.dart';
import 'package:remind/features/tasks/domain/group_task.dart';
import 'package:remind/features/tasks/domain/task_repository.dart';
import 'package:remind/features/tasks/presentation/task_detail_screen.dart';
import 'package:remind/features/tasks/presentation/task_providers.dart';

import '../../../support/recording_auth_repository.dart';

void main() {
  testWidgets('signed-in user marks task complete from detail screen',
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
    final taskRepository = _RecordingTaskRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          groupRepositoryProvider
              .overrideWithValue(_RecordingGroupRepository()),
          taskRepositoryProvider.overrideWithValue(taskRepository),
        ],
        child: const MaterialApp(
          home: TaskDetailScreen(groupId: 'family', taskId: 'task-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();

    expect(taskRepository.completions.single.taskId, 'task-1');
    expect(find.text('Task completed.'), findsOneWidget);
  });
}

final class _RecordingGroupRepository implements GroupRepository {
  @override
  Stream<Group?> watchGroup(String groupId) => Stream.value(
        Group(
          id: groupId,
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
          ],
        ),
      );

  @override
  Future<void> createGroup(Group group) async {}

  @override
  Future<void> createInvite(GroupInvite invite) async {}

  @override
  Future<void> acceptInvite(GroupInviteAcceptance acceptance) async {}
}

final class _RecordingTaskRepository implements TaskRepository {
  final completions = <GroupTaskCompletion>[];
  final _controller = StreamController<GroupTask?>.broadcast();
  late GroupTask _task = GroupTask(
    id: 'task-1',
    groupId: 'family',
    title: 'Buy milk',
    notes: 'Use the shared card',
    createdBy: 'uid-1',
    assignedTo: 'uid-1',
    priority: GroupTaskPriority.normal,
    status: GroupTaskStatus.open,
    createdAt: DateTime.utc(2026, 6, 7),
    updatedAt: DateTime.utc(2026, 6, 7),
  );

  @override
  Stream<List<GroupTask>> watchGroupTasks(String groupId) =>
      Stream.value([_task]);

  @override
  Stream<GroupTask?> watchTask(
      {required String groupId, required String taskId}) async* {
    yield _task;
    yield* _controller.stream;
  }

  @override
  Future<void> createTask(GroupTask task) async {}

  @override
  Future<void> completeTask(GroupTaskCompletion completion) async {
    completions.add(completion);
    _task = GroupTask(
      id: _task.id,
      groupId: _task.groupId,
      title: _task.title,
      notes: _task.notes,
      createdBy: _task.createdBy,
      assignedTo: _task.assignedTo,
      priority: _task.priority,
      status: GroupTaskStatus.completed,
      createdAt: _task.createdAt,
      updatedAt: completion.completedAt,
      completedAt: completion.completedAt,
      completedBy: completion.completedBy,
    );
    _controller.add(_task);
  }
}
