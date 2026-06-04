import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/queue/domain/saved_item.dart';
import 'package:remind/features/queue/domain/smart_queue.dart';
import 'package:remind/features/queue/domain/smart_queue_engine.dart';

void main() {
  final now = DateTime.utc(2026, 6, 4, 20);
  final engine = SmartQueueEngine(now: now);

  test('tonight queue includes items saved after 6pm today', () {
    final items = [
      item(id: 'morning', savedAt: DateTime.utc(2026, 6, 4, 9)),
      item(id: 'evening', savedAt: DateTime.utc(2026, 6, 4, 19)),
    ];

    expect(engine.itemsFor(SmartQueueType.tonight, items).map((item) => item.id), ['evening']);
  });

  test('forgotten queue includes old incomplete items oldest first', () {
    final items = [
      item(id: 'new', savedAt: DateTime.utc(2026, 6, 1)),
      item(id: 'oldest', savedAt: DateTime.utc(2026, 5, 1)),
      item(id: 'old', savedAt: DateTime.utc(2026, 5, 20)),
    ];

    expect(engine.itemsFor(SmartQueueType.forgotten, items).map((item) => item.id), ['oldest', 'old']);
  });

  test('continue reading queue includes partial progress ordered by last opened', () {
    final items = [
      item(
        id: 'older',
        readingProgress: 0.4,
        lastOpenedAt: DateTime.utc(2026, 6, 2),
      ),
      item(
        id: 'recent',
        readingProgress: 0.7,
        lastOpenedAt: DateTime.utc(2026, 6, 3),
      ),
      item(id: 'done', readingProgress: 1),
    ];

    expect(engine.itemsFor(SmartQueueType.continueReading, items).map((item) => item.id), ['recent', 'older']);
  });
}

SavedItem item({
  required String id,
  DateTime? savedAt,
  ItemCategory category = ItemCategory.article,
  double readingProgress = 0,
  DateTime? lastOpenedAt,
}) {
  final createdAt = savedAt ?? DateTime.utc(2026, 6, 4, 12);
  return SavedItem(
    id: id,
    ownerId: 'owner',
    title: id,
    url: 'https://example.com/$id',
    category: category,
    savedAt: createdAt,
    updatedAt: createdAt,
    readingProgress: readingProgress,
    lastOpenedAt: lastOpenedAt,
  );
}
