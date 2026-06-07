import '../domain/group_models.dart';
import '../domain/group_repository.dart';

final class UnavailableGroupRepository implements GroupRepository {
  const UnavailableGroupRepository();

  @override
  Future<void> createGroup(Group group) {
    throw StateError('Firebase is not configured yet. Add google-services.json before creating shared groups.');
  }
}
