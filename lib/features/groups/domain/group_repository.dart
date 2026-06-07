import 'group_models.dart';

abstract interface class GroupRepository {
  Stream<Group?> watchGroup(String groupId);

  Future<void> createGroup(Group group);

  Future<void> createInvite(GroupInvite invite);

  Future<void> acceptInvite(GroupInviteAcceptance acceptance);
}
