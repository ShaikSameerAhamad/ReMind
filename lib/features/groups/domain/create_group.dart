import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'group_models.dart';
import 'group_repository.dart';

sealed class CreateGroupResult {
  const CreateGroupResult();
}

final class CreateGroupSuccess extends CreateGroupResult {
  const CreateGroupSuccess(this.group);

  final Group group;
}

final class CreateGroupFailure extends CreateGroupResult {
  const CreateGroupFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is CreateGroupFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class CreateGroup {
  const CreateGroup({
    required GroupRepository repository,
    required DateTime Function() now,
    required String Function() idGenerator,
  })  : _repository = repository,
        _now = now,
        _idGenerator = idGenerator;

  final GroupRepository _repository;
  final DateTime Function() _now;
  final String Function() _idGenerator;

  Future<CreateGroupResult> call({
    required AuthSession session,
    required String name,
  }) async {
    if (!session.canUseCloud || session.profile == null) {
      return const CreateGroupFailure(Invalid('Sign in to create shared groups.'));
    }

    final validation = ReMindValidators.groupName(name);
    if (validation is Invalid) {
      return CreateGroupFailure(validation);
    }

    final timestamp = _now().toUtc();
    final profile = session.profile!;
    final group = Group(
      id: _idGenerator(),
      name: name.trim(),
      createdBy: profile.uid,
      createdAt: timestamp,
      updatedAt: timestamp,
      lastActivityAt: timestamp,
      members: [
        GroupMembership(
          userId: profile.uid,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
          role: GroupRole.admin,
          joinedAt: timestamp,
        ),
      ],
    );
    await _repository.createGroup(group);
    return CreateGroupSuccess(group);
  }
}
