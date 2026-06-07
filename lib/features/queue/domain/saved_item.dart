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

  SavedItem copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? url,
    ItemCategory? category,
    String? sourceDomain,
    String? thumbnailUrl,
    int? readTimeMinutes,
    DateTime? savedAt,
    DateTime? updatedAt,
    DateTime? reminderAt,
    bool? isCompleted,
    bool? isArchived,
    double? readingProgress,
    DateTime? lastOpenedAt,
    List<String>? tags,
    SyncStatus? syncStatus,
  }) {
    return SavedItem(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      url: url ?? this.url,
      category: category ?? this.category,
      sourceDomain: sourceDomain ?? this.sourceDomain,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      savedAt: savedAt ?? this.savedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderAt: reminderAt ?? this.reminderAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      readingProgress: readingProgress ?? this.readingProgress,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      tags: tags ?? this.tags,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
