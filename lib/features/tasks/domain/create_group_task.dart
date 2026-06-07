import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'group_task.dart';
import 'task_repository.dart';

sealed class CreateGroupTaskResult {
  const CreateGroupTaskResult();
}

final class CreateGroupTaskSuccess extends CreateGroupTaskResult {
  const CreateGroupTaskSuccess(this.task);

  final GroupTask task;
}

final class CreateGroupTaskFailure extends CreateGroupTaskResult {
  const CreateGroupTaskFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is CreateGroupTaskFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class CreateGroupTask {
  const CreateGroupTask({
    required TaskRepository repository,
    required DateTime Function() now,
    required String Function() idGenerator,
  })  : _repository = repository,
        _now = now,
        _idGenerator = idGenerator;

  final TaskRepository _repository;
  final DateTime Function() _now;
  final String Function() _idGenerator;

  Future<CreateGroupTaskResult> call({
    required AuthSession session,
    required String groupId,
    required String title,
    required String? notes,
    required String? assignedTo,
    required GroupTaskPriority priority,
    required DateTime? dueAt,
  }) async {
    if (!session.canUseCloud || session.profile == null) {
      return const CreateGroupTaskFailure(
          Invalid('Sign in to create shared tasks.'));
    }

    final validation = ReMindValidators.taskTitle(title);
    if (validation is Invalid) {
      return CreateGroupTaskFailure(validation);
    }

    final trimmedGroupId = groupId.trim();
    if (trimmedGroupId.isEmpty) {
      return const CreateGroupTaskFailure(Invalid('Group is required.'));
    }
    if (trimmedGroupId.contains('/')) {
      return const CreateGroupTaskFailure(Invalid('Group is invalid.'));
    }

    final normalizedAssignee = _optionalSegment(assignedTo);
    if (normalizedAssignee == '') {
      return const CreateGroupTaskFailure(Invalid('Assignee is invalid.'));
    }

    final timestamp = _now().toUtc();
    final task = GroupTask(
      id: _idGenerator(),
      groupId: trimmedGroupId,
      title: title.trim(),
      notes: _optionalText(notes),
      createdBy: session.profile!.uid,
      assignedTo: normalizedAssignee,
      priority: priority,
      status: GroupTaskStatus.open,
      createdAt: timestamp,
      updatedAt: timestamp,
      dueAt: dueAt?.toUtc(),
    );
    await _repository.createTask(task);
    return CreateGroupTaskSuccess(task);
  }

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _optionalSegment(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed.contains('/') ? '' : trimmed;
  }
}
