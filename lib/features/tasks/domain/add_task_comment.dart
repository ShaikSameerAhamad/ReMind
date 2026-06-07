import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'group_task.dart';
import 'task_repository.dart';

sealed class AddTaskCommentResult {
  const AddTaskCommentResult();
}

final class AddTaskCommentSuccess extends AddTaskCommentResult {
  const AddTaskCommentSuccess(this.comment);

  final TaskComment comment;
}

final class AddTaskCommentFailure extends AddTaskCommentResult {
  const AddTaskCommentFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is AddTaskCommentFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class AddTaskComment {
  const AddTaskComment({
    required TaskRepository repository,
    required DateTime Function() now,
    required String Function() idGenerator,
  })  : _repository = repository,
        _now = now,
        _idGenerator = idGenerator;

  final TaskRepository _repository;
  final DateTime Function() _now;
  final String Function() _idGenerator;

  Future<AddTaskCommentResult> call({
    required AuthSession session,
    required String groupId,
    required String taskId,
    required String text,
  }) async {
    if (!session.canUseCloud || session.profile == null) {
      return const AddTaskCommentFailure(
          Invalid('Sign in to comment on shared tasks.'));
    }

    final trimmedGroupId = groupId.trim();
    final trimmedTaskId = taskId.trim();
    if (trimmedGroupId.isEmpty || trimmedTaskId.isEmpty) {
      return const AddTaskCommentFailure(Invalid('Task is required.'));
    }
    if (trimmedGroupId.contains('/') || trimmedTaskId.contains('/')) {
      return const AddTaskCommentFailure(Invalid('Task is invalid.'));
    }

    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return const AddTaskCommentFailure(Invalid('Comment is required.'));
    }
    if (trimmedText.length > 500) {
      return const AddTaskCommentFailure(
          Invalid('Comment must be 500 characters or less.'));
    }

    final profile = session.profile!;
    final comment = TaskComment(
      groupId: trimmedGroupId,
      taskId: trimmedTaskId,
      id: _idGenerator(),
      authorId: profile.uid,
      authorName: profile.displayName,
      text: trimmedText,
      createdAt: _now().toUtc(),
    );
    await _repository.addComment(comment);
    return AddTaskCommentSuccess(comment);
  }
}
