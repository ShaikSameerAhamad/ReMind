enum ItemCategory { article, video, product, social, recipe, learning, note }

enum SyncStatus { synced, pending, failed }

final class SavedItem {
  const SavedItem({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.url,
    required this.category,
    required this.savedAt,
    required this.updatedAt,
    this.sourceDomain,
    this.thumbnailUrl,
    this.readTimeMinutes,
    this.reminderAt,
    this.isCompleted = false,
    this.isArchived = false,
    this.readingProgress = 0,
    this.lastOpenedAt,
    this.tags = const [],
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String ownerId;
  final String title;
  final String url;
  final ItemCategory category;
  final String? sourceDomain;
  final String? thumbnailUrl;
  final int? readTimeMinutes;
  final DateTime savedAt;
  final DateTime updatedAt;
  final DateTime? reminderAt;
  final bool isCompleted;
  final bool isArchived;
  final double readingProgress;
  final DateTime? lastOpenedAt;
  final List<String> tags;
  final SyncStatus syncStatus;
}
