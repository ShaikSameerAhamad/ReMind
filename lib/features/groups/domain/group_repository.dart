import 'group_models.dart';

abstract interface class GroupRepository {
  Future<void> createGroup(Group group);
}
