enum GroupRole { admin, member }

enum SubscriptionPlan { free, pro, family }

sealed class UserAccess {
  const UserAccess();

  bool get canCreateCloudGroup;
}

final class GuestAccess extends UserAccess {
  const GuestAccess();

  @override
  bool get canCreateCloudGroup => false;
}

final class SignedInAccess extends UserAccess {
  const SignedInAccess({required this.plan});

  final SubscriptionPlan plan;

  @override
  bool get canCreateCloudGroup => true;
}

final class GroupMembership {
  const GroupMembership({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final GroupRole role;
  final DateTime joinedAt;
  final String? avatarUrl;

  bool get canManageMembers => role == GroupRole.admin;

  bool canDeleteTask({required String createdBy}) {
    return role == GroupRole.admin || createdBy == userId;
  }
}
