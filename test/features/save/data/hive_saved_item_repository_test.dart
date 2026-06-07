import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:remind/features/queue/domain/saved_item.dart';
import 'package:remind/features/save/data/hive_saved_item_repository.dart';

void main() {
  late Box<Map> box;
  late HiveSavedItemRepository repository;

  setUp(() async {
    Hive.init('build/test_hive_${DateTime.now().microsecondsSinceEpoch}');
    box = await Hive.openBox<Map>('saved_items');
    repository = HiveSavedItemRepository(box: box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
  });

  test('watchItems emits saved items for the requested owner only', () async {
    final ownerItem = item(id: 'mine', ownerId: 'owner');
    final otherItem = item(id: 'other', ownerId: 'someone-else');

    await repository.save(ownerItem);
    await repository.save(otherItem);

    final items = await repository.watchItems(ownerId: 'owner').first;

    expect(items.map((item) => item.id), ['mine']);
  });

  test('save persists item with pending sync status', () async {
    final saved = item(id: 'pending', ownerId: 'owner', syncStatus: SyncStatus.pending);

    await repository.save(saved);
    final items = await repository.watchItems(ownerId: 'owner').first;

    expect(items.single.syncStatus, SyncStatus.pending);
  });
}

SavedItem item({
  required String id,
  required String ownerId,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return SavedItem(
    id: id,
    ownerId: ownerId,
    title: 'Saved $id',
    url: 'https://example.com/$id',
    category: ItemCategory.article,
    savedAt: DateTime.utc(2026, 6, 7),
    updatedAt: DateTime.utc(2026, 6, 7),
    syncStatus: syncStatus,
  );
}
