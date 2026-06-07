import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/tasks/domain/add_task_comment.dart';
import 'package:remind/features/tasks/domain/group_task.dart';
import 'package:remind/features/tasks/domain/task_repository.dart';

void main() {
  test('addTaskComment rejects guests before writing', () async {
    final repository = _RecordingTaskRepository();
    final useCase = AddTaskComment(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'comment-1',
    );

    final result = await useCase(
      session: AuthSession.guest(deviceId: 'device-1'),
      groupId: 'family',
      taskId: 'task-1',
      text: 'Done',
    );

    expect(
        result,
        const AddTaskCommentFailure(
            Invalid('Sign in to comment on shared tasks.')));
    expect(repository.comments, isEmpty);
  });

  test('addTaskComment validates comment text before writing', () async {
    final repository = _RecordingTaskRepository();
    final useCase = AddTaskComment(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'comment-1',
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      taskId: 'task-1',
      text: ' ',
    );

    expect(
        result, const AddTaskCommentFailure(Invalid('Comment is required.')));
    expect(repository.comments, isEmpty);
  });

  test('addTaskComment writes signed-in author metadata', () async {
    final repository = _RecordingTaskRepository();
    final useCase = AddTaskComment(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'comment-1',
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: ' family ',
      taskId: ' task-1 ',
      text: '  Picked this up  ',
    );

    expect(result, isA<AddTaskCommentSuccess>());
    final comment = repository.comments.single;
    expect(comment.groupId, 'family');
    expect(comment.taskId, 'task-1');
    expect(comment.id, 'comment-1');
    expect(comment.text, 'Picked this up');
    expect(comment.authorId, 'uid-1');
    expect(comment.authorName, 'Sameer');
    expect(comment.createdAt, DateTime.utc(2026, 6, 7, 10));
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
  final comments = <TaskComment>[];

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
  Future<void> completeTask(GroupTaskCompletion completion) async {}

  @override
  Future<void> addComment(TaskComment comment) async {
    comments.add(comment);
  }
}
