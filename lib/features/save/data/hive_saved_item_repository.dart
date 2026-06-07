import 'package:hive_ce/hive.dart';

import '../../queue/domain/saved_item.dart';
import '../domain/saved_item_codec.dart';
import '../domain/saved_item_repository.dart';

final class HiveSavedItemRepository implements SavedItemRepository {
  HiveSavedItemRepository({required Box<Map> box}) : _box = box;

  final Box<Map> _box;

  @override
  Stream<List<SavedItem>> watchItems({required String ownerId}) async* {
    yield _itemsFor(ownerId);
    yield* _box.watch().map((_) => _itemsFor(ownerId));
  }

  @override
  Future<void> save(SavedItem item) {
    return _box.put(item.id, SavedItemCodec.toJson(item));
  }

  List<SavedItem> _itemsFor(String ownerId) {
    final items = _box.values
        .map(SavedItemCodec.fromJson)
        .where((item) => item.ownerId == ownerId)
        .toList();
    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return items;
  }
}
