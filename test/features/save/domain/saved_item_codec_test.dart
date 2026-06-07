import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/queue/domain/saved_item.dart';
import 'package:remind/features/save/domain/saved_item_codec.dart';

void main() {
  test('saved item codec round trips all sync-critical fields', () {
    final item = SavedItem(
      id: 'item-1',
      ownerId: 'guest-device',
      title: 'Offline-first article',
      url: 'https://example.com/offline',
      category: ItemCategory.article,
      sourceDomain: 'example.com',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      readTimeMinutes: 8,
      savedAt: DateTime.utc(2026, 6, 7, 10),
      updatedAt: DateTime.utc(2026, 6, 7, 11),
      reminderAt: DateTime.utc(2026, 6, 7, 20),
      isCompleted: true,
      isArchived: false,
      readingProgress: 0.72,
      lastOpenedAt: DateTime.utc(2026, 6, 7, 12),
      tags: const ['learning', 'weekend'],
      syncStatus: SyncStatus.pending,
    );

    final encoded = SavedItemCodec.toJson(item);
    final decoded = SavedItemCodec.fromJson(encoded);

    expect(decoded.id, item.id);
    expect(decoded.ownerId, item.ownerId);
    expect(decoded.title, item.title);
    expect(decoded.url, item.url);
    expect(decoded.category, item.category);
    expect(decoded.sourceDomain, item.sourceDomain);
    expect(decoded.thumbnailUrl, item.thumbnailUrl);
    expect(decoded.readTimeMinutes, item.readTimeMinutes);
    expect(decoded.savedAt, item.savedAt);
    expect(decoded.updatedAt, item.updatedAt);
    expect(decoded.reminderAt, item.reminderAt);
    expect(decoded.isCompleted, item.isCompleted);
    expect(decoded.isArchived, item.isArchived);
    expect(decoded.readingProgress, item.readingProgress);
    expect(decoded.lastOpenedAt, item.lastOpenedAt);
    expect(decoded.tags, item.tags);
    expect(decoded.syncStatus, item.syncStatus);
  });
}
