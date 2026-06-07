import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'group_models.dart';
import 'group_repository.dart';

sealed class AcceptGroupInviteResult {
  const AcceptGroupInviteResult();
}

final class AcceptGroupInviteSuccess extends AcceptGroupInviteResult {
  const AcceptGroupInviteSuccess(this.groupId);

  final String groupId;
}

final class AcceptGroupInviteFailure extends AcceptGroupInviteResult {
  const AcceptGroupInviteFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is AcceptGroupInviteFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class AcceptGroupInvite {
  const AcceptGroupInvite({
    required GroupRepository repository,
    required DateTime Function() now,
  })  : _repository = repository,
        _now = now;

  final GroupRepository _repository;
  final DateTime Function() _now;

  Future<AcceptGroupInviteResult> call({
    required AuthSession session,
    required String groupId,
    required String inviteCode,
  }) async {
    if (!session.canUseCloud || session.profile == null) {
      return const AcceptGroupInviteFailure(
          Invalid('Sign in to join this group.'));
    }

    final trimmedGroupId = groupId.trim();
    final trimmedInviteCode = inviteCode.trim();
    if (trimmedGroupId.isEmpty || trimmedInviteCode.isEmpty) {
      return const AcceptGroupInviteFailure(
          Invalid('Invite link is incomplete.'));
    }
    if (trimmedGroupId.contains('/') || trimmedInviteCode.contains('/')) {
      return const AcceptGroupInviteFailure(Invalid('Invite link is invalid.'));
    }

    final profile = session.profile!;
    final acceptedAt = _now().toUtc();
    final acceptance = GroupInviteAcceptance(
      groupId: trimmedGroupId,
      inviteCode: trimmedInviteCode,
      acceptedAt: acceptedAt,
      member: GroupMembership(
        userId: profile.uid,
        displayName: profile.displayName,
        avatarUrl: profile.avatarUrl,
        role: GroupRole.member,
        joinedAt: acceptedAt,
      ),
    );

    try {
      await _repository.acceptInvite(acceptance);
    } on GroupInviteAcceptanceException catch (error) {
      return AcceptGroupInviteFailure(Invalid(error.message));
    }
    return AcceptGroupInviteSuccess(trimmedGroupId);
  }
}

final class GroupInviteAcceptanceException implements Exception {
  const GroupInviteAcceptanceException(this.message);

  final String message;
}
