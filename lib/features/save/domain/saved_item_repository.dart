import '../../queue/domain/saved_item.dart';

abstract interface class SavedItemRepository {
  Stream<List<SavedItem>> watchItems({required String ownerId});

  Future<void> save(SavedItem item);
}
