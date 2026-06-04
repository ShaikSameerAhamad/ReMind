import 'saved_item.dart';
import 'smart_queue.dart';

final class SmartQueueEngine {
  const SmartQueueEngine({required this.now});

  final DateTime now;

  List<SavedItem> itemsFor(SmartQueueType queue, Iterable<SavedItem> items) {
    final activeItems = items.where((item) => !item.isArchived).toList();
    final filtered = activeItems.where((item) => _belongs(queue, item)).toList();
    filtered.sort((a, b) => _compare(queue, a, b));
    return filtered;
  }

  bool _belongs(SmartQueueType queue, SavedItem item) {
    return switch (queue) {
      SmartQueueType.tonight => _isTonight(item),
      SmartQueueType.weekend => item.tags.contains('weekend'),
      SmartQueueType.forgotten => !item.isCompleted && now.difference(item.savedAt).inDays > 7,
      SmartQueueType.continueReading => item.readingProgress >= 0.30 && item.readingProgress < 1,
      SmartQueueType.watchLater => item.category == ItemCategory.video,
      SmartQueueType.learning => item.category == ItemCategory.learning || item.tags.contains('learning'),
      SmartQueueType.recentlySaved => now.difference(item.savedAt).inHours <= 48,
    };
  }

  bool _isTonight(SavedItem item) {
    final reminder = item.reminderAt;
    if (reminder != null && _sameDay(reminder, now) && reminder.hour >= 18) {
      return true;
    }
    return _sameDay(item.savedAt, now) && item.savedAt.hour >= 18;
  }

  int _compare(SmartQueueType queue, SavedItem a, SavedItem b) {
    return switch (queue) {
      SmartQueueType.tonight => _date(a.reminderAt ?? a.savedAt).compareTo(_date(b.reminderAt ?? b.savedAt)),
      SmartQueueType.weekend => b.savedAt.compareTo(a.savedAt),
      SmartQueueType.forgotten => a.savedAt.compareTo(b.savedAt),
      SmartQueueType.continueReading => (b.lastOpenedAt ?? b.updatedAt).compareTo(a.lastOpenedAt ?? a.updatedAt),
      SmartQueueType.watchLater => (a.readTimeMinutes ?? 0).compareTo(b.readTimeMinutes ?? 0),
      SmartQueueType.learning => b.savedAt.compareTo(a.savedAt),
      SmartQueueType.recentlySaved => b.savedAt.compareTo(a.savedAt),
    };
  }

  DateTime _date(DateTime value) => value;

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
