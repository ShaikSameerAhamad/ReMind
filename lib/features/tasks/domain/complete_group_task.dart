import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'group_task.dart';
import 'task_repository.dart';

sealed class CompleteGroupTaskResult {
  const CompleteGroupTaskResult();
}

final class CompleteGroupTaskSuccess extends CompleteGroupTaskResult {
  const CompleteGroupTaskSuccess(this.taskId);

  final String taskId;

  @override
  bool operator ==(Object other) {
    return other is CompleteGroupTaskSuccess && other.taskId == taskId;
  }

  @override
  int get hashCode => taskId.hashCode;
}

final class CompleteGroupTaskFailure extends CompleteGroupTaskResult {
  const CompleteGroupTaskFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is CompleteGroupTaskFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class CompleteGroupTask {
  const CompleteGroupTask({
    required TaskRepository repository,
    required DateTime Function() now,
  })  : _repository = repository,
        _now = now;

  final TaskRepository _repository;
  final DateTime Function() _now;

  Future<CompleteGroupTaskResult> call({
    required AuthSession session,
    required String groupId,
    required String taskId,
  }) async {
    if (!session.canUseCloud || session.profile == null) {
      return const CompleteGroupTaskFailure(
          Invalid('Sign in to complete shared tasks.'));
    }

    final trimmedGroupId = groupId.trim();
    final trimmedTaskId = taskId.trim();
    if (trimmedGroupId.isEmpty || trimmedTaskId.isEmpty) {
      return const CompleteGroupTaskFailure(Invalid('Task is required.'));
    }
    if (trimmedGroupId.contains('/') || trimmedTaskId.contains('/')) {
      return const CompleteGroupTaskFailure(Invalid('Task is invalid.'));
    }

    await _repository.completeTask(
      GroupTaskCompletion(
        groupId: trimmedGroupId,
        taskId: trimmedTaskId,
        completedBy: session.profile!.uid,
        completedAt: _now().toUtc(),
      ),
    );
    return CompleteGroupTaskSuccess(trimmedTaskId);
  }
}
