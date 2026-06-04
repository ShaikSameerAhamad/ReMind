import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/groups/domain/group_models.dart';

void main() {
  test('group admin can manage members and delete tasks created by others', () {
    final membership = GroupMembership(
      userId: 'admin',
      displayName: 'Admin',
      role: GroupRole.admin,
      joinedAt: DateTime.utc(2026),
    );

    expect(membership.canManageMembers, isTrue);
    expect(membership.canDeleteTask(createdBy: 'member'), isTrue);
  });

  test('group member can delete own task but not others task', () {
    final membership = GroupMembership(
      userId: 'member',
      displayName: 'Member',
      role: GroupRole.member,
      joinedAt: DateTime.utc(2026),
    );

    expect(membership.canManageMembers, isFalse);
    expect(membership.canDeleteTask(createdBy: 'member'), isTrue);
    expect(membership.canDeleteTask(createdBy: 'other'), isFalse);
  });

  test('guest access cannot create cloud groups', () {
    expect(const GuestAccess().canCreateCloudGroup, isFalse);
    expect(const SignedInAccess(plan: SubscriptionPlan.free).canCreateCloudGroup, isTrue);
  });
}
