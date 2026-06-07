import '../../features/queue/domain/saved_item.dart';

abstract interface class SavedItemRemoteStore {
  Future<void> upsertSavedItem(SavedItem item);
}
