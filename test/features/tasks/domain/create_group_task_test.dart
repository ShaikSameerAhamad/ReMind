import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/tasks/domain/create_group_task.dart';
import 'package:remind/features/tasks/domain/group_task.dart';
import 'package:remind/features/tasks/domain/task_repository.dart';

void main() {
  test('createGroupTask rejects guest sessions before writing', () async {
    final repository = _RecordingTaskRepository();
    final useCase = CreateGroupTask(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'task-1',
    );

    final result = await useCase(
      session: AuthSession.guest(deviceId: 'device-1'),
      groupId: 'family',
      title: 'Buy milk',
      notes: null,
      assignedTo: null,
      priority: GroupTaskPriority.normal,
      dueAt: null,
    );

    expect(
        result,
        const CreateGroupTaskFailure(
            Invalid('Sign in to create shared tasks.')));
    expect(repository.createdTasks, isEmpty);
  });

  test('createGroupTask validates title before writing', () async {
    final repository = _RecordingTaskRepository();
    final useCase = CreateGroupTask(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'task-1',
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      title: ' ',
      notes: null,
      assignedTo: null,
      priority: GroupTaskPriority.normal,
      dueAt: null,
    );

    expect(result,
        const CreateGroupTaskFailure(Invalid('Task title is required.')));
    expect(repository.createdTasks, isEmpty);
  });

  test('createGroupTask writes normalized task data', () async {
    final repository = _RecordingTaskRepository();
    final useCase = CreateGroupTask(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'task-1',
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: ' family ',
      title: '  Buy milk  ',
      notes: '  Organic if available  ',
      assignedTo: ' uid-2 ',
      priority: GroupTaskPriority.high,
      dueAt: DateTime.utc(2026, 6, 8, 9),
    );

    expect(result, isA<CreateGroupTaskSuccess>());
    final task = repository.createdTasks.single;
    expect(task.id, 'task-1');
    expect(task.groupId, 'family');
    expect(task.title, 'Buy milk');
    expect(task.notes, 'Organic if available');
    expect(task.createdBy, 'uid-1');
    expect(task.assignedTo, 'uid-2');
    expect(task.priority, GroupTaskPriority.high);
    expect(task.status, GroupTaskStatus.open);
    expect(task.createdAt, DateTime.utc(2026, 6, 7, 10));
    expect(task.updatedAt, DateTime.utc(2026, 6, 7, 10));
    expect(task.dueAt, DateTime.utc(2026, 6, 8, 9));
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

final class _RecordingTaskRepository implements TaskRepository {
  final createdTasks = <GroupTask>[];

  @override
  Stream<List<GroupTask>> watchGroupTasks(String groupId) =>
      const Stream.empty();

  @override
  Stream<GroupTask?> watchTask(
          {required String groupId, required String taskId}) =>
      const Stream.empty();

  @override
  Future<void> createTask(GroupTask task) async {
    createdTasks.add(task);
  }

  @override
  Future<void> completeTask(GroupTaskCompletion completion) async {}

  @override
  Future<void> addComment(TaskComment comment) async {}
}
