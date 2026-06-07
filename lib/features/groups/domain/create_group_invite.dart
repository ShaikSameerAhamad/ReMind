import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'group_models.dart';
import 'group_repository.dart';

sealed class CreateGroupInviteResult {
  const CreateGroupInviteResult();
}

final class CreateGroupInviteSuccess extends CreateGroupInviteResult {
  const CreateGroupInviteSuccess(this.invite);

  final GroupInvite invite;
}

final class CreateGroupInviteFailure extends CreateGroupInviteResult {
  const CreateGroupInviteFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is CreateGroupInviteFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class CreateGroupInvite {
  const CreateGroupInvite({
    required GroupRepository repository,
    required DateTime Function() now,
    required String Function() codeGenerator,
  })  : _repository = repository,
        _now = now,
        _codeGenerator = codeGenerator;

  final GroupRepository _repository;
  final DateTime Function() _now;
  final String Function() _codeGenerator;

  Future<CreateGroupInviteResult> call({
    required AuthSession session,
    required String groupId,
    required String? recipientEmail,
  }) async {
    if (!session.canUseCloud || session.profile == null) {
      return const CreateGroupInviteFailure(
          Invalid('Sign in to invite group members.'));
    }

    final trimmedGroupId = groupId.trim();
    if (trimmedGroupId.isEmpty) {
      return const CreateGroupInviteFailure(Invalid('Group is required.'));
    }
    if (trimmedGroupId.contains('/')) {
      return const CreateGroupInviteFailure(Invalid('Group is invalid.'));
    }

    final timestamp = _now().toUtc();
    final code = _codeGenerator().trim();
    final invite = GroupInvite(
      groupId: trimmedGroupId,
      code: code,
      deepLink:
          '${AppConstants.inviteScheme}://groups/$trimmedGroupId/invites/$code',
      createdBy: session.profile!.uid,
      recipientEmail: _normalizedEmail(recipientEmail),
      createdAt: timestamp,
      expiresAt: timestamp.add(const Duration(days: 7)),
    );
    await _repository.createInvite(invite);
    return CreateGroupInviteSuccess(invite);
  }

  String? _normalizedEmail(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
