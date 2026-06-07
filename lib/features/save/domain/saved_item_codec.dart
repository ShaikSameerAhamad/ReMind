import '../../queue/domain/saved_item.dart';

abstract final class SavedItemCodec {
  static Map<String, Object?> toJson(SavedItem item) {
    return {
      'id': item.id,
      'ownerId': item.ownerId,
      'title': item.title,
      'url': item.url,
      'category': item.category.name,
      'sourceDomain': item.sourceDomain,
      'thumbnailUrl': item.thumbnailUrl,
      'readTimeMinutes': item.readTimeMinutes,
      'savedAt': item.savedAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
      'reminderAt': item.reminderAt?.toIso8601String(),
      'isCompleted': item.isCompleted,
      'isArchived': item.isArchived,
      'readingProgress': item.readingProgress,
      'lastOpenedAt': item.lastOpenedAt?.toIso8601String(),
      'tags': item.tags,
      'syncStatus': item.syncStatus.name,
    };
  }

  static SavedItem fromJson(Map<dynamic, dynamic> json) {
    return SavedItem(
      id: json.requireString('id'),
      ownerId: json.requireString('ownerId'),
      title: json.requireString('title'),
      url: json.requireString('url'),
      category: ItemCategory.values.byName(json.requireString('category')),
      sourceDomain: json.optionalString('sourceDomain'),
      thumbnailUrl: json.optionalString('thumbnailUrl'),
      readTimeMinutes: json.optionalInt('readTimeMinutes'),
      savedAt: DateTime.parse(json.requireString('savedAt')),
      updatedAt: DateTime.parse(json.requireString('updatedAt')),
      reminderAt: json.optionalDateTime('reminderAt'),
      isCompleted: json.optionalBool('isCompleted') ?? false,
      isArchived: json.optionalBool('isArchived') ?? false,
      readingProgress: json.optionalDouble('readingProgress') ?? 0,
      lastOpenedAt: json.optionalDateTime('lastOpenedAt'),
      tags: json.optionalStringList('tags'),
      syncStatus: SyncStatus.values.byName(json.optionalString('syncStatus') ?? SyncStatus.synced.name),
    );
  }
}

extension _SavedItemJson on Map<dynamic, dynamic> {
  String requireString(String key) {
    final value = this[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('Saved item field "$key" is required.');
  }

  String? optionalString(String key) {
    final value = this[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  int? optionalInt(String key) {
    final value = this[key];
    return value is int ? value : null;
  }

  bool? optionalBool(String key) {
    final value = this[key];
    return value is bool ? value : null;
  }

  double? optionalDouble(String key) {
    final value = this[key];
    return switch (value) {
      final double number => number,
      final int number => number.toDouble(),
      _ => null,
    };
  }

  DateTime? optionalDateTime(String key) {
    final value = optionalString(key);
    return value == null ? null : DateTime.parse(value);
  }

  List<String> optionalStringList(String key) {
    final value = this[key];
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
