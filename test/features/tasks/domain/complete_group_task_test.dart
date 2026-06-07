import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/tasks/domain/complete_group_task.dart';
import 'package:remind/features/tasks/domain/group_task.dart';
import 'package:remind/features/tasks/domain/task_repository.dart';

void main() {
  test('completeGroupTask rejects signed-out sessions before writing',
      () async {
    final repository = _RecordingTaskRepository();
    final useCase = CompleteGroupTask(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: const AuthSession.signedOut(),
      groupId: 'family',
      taskId: 'task-1',
    );

    expect(
        result,
        const CompleteGroupTaskFailure(
            Invalid('Sign in to complete shared tasks.')));
    expect(repository.completions, isEmpty);
  });

  test('completeGroupTask writes completion metadata', () async {
    final repository = _RecordingTaskRepository();
    final useCase = CompleteGroupTask(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      taskId: 'task-1',
    );

    expect(result, const CompleteGroupTaskSuccess('task-1'));
    final completion = repository.completions.single;
    expect(completion.groupId, 'family');
    expect(completion.taskId, 'task-1');
    expect(completion.completedBy, 'uid-1');
    expect(completion.completedAt, DateTime.utc(2026, 6, 7, 10));
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
  final completions = <GroupTaskCompletion>[];

  @override
  Stream<List<GroupTask>> watchGroupTasks(String groupId) =>
      const Stream.empty();

  @override
  Stream<GroupTask?> watchTask(
          {required String groupId, required String taskId}) =>
      const Stream.empty();

  @override
  Future<void> createTask(GroupTask task) async {}

  @override
  Future<void> completeTask(GroupTaskCompletion completion) async {
    completions.add(completion);
  }

  @override
  Future<void> addComment(TaskComment comment) async {}
}
