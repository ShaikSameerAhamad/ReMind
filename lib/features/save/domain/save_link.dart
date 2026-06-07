import 'dart:math';

import '../../../core/utils/validation.dart';
import '../../queue/domain/saved_item.dart';
import 'saved_item_repository.dart';

sealed class SaveLinkResult {
  const SaveLinkResult();
}

final class SaveLinkSuccess extends SaveLinkResult {
  const SaveLinkSuccess(this.item);

  final SavedItem item;
}

final class SaveLinkFailure extends SaveLinkResult {
  const SaveLinkFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is SaveLinkFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class SaveLink {
  SaveLink({
    required SavedItemRepository repository,
    required DateTime Function() now,
    Random? random,
  })  : _repository = repository,
        _now = now,
        _random = random ?? Random.secure();

  final SavedItemRepository _repository;
  final DateTime Function() _now;
  final Random _random;

  Future<SaveLinkResult> call({
    required String ownerId,
    required String url,
    required String title,
  }) async {
    final validation = ReMindValidators.secureUrl(url);
    if (validation is Invalid) {
      return SaveLinkFailure(validation);
    }

    final uri = Uri.parse(url.trim());
    final timestamp = _now().toUtc();
    final item = SavedItem(
      id: _newId(timestamp),
      ownerId: ownerId,
      title: title.trim().isEmpty ? uri.host : title.trim(),
      url: uri.toString(),
      category: ItemCategory.article,
      sourceDomain: uri.host,
      savedAt: timestamp,
      updatedAt: timestamp,
      syncStatus: SyncStatus.synced,
    );
    await _repository.save(item);
    return SaveLinkSuccess(item);
  }

  String _newId(DateTime timestamp) {
    final randomPart = List.generate(8, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return 'item-${timestamp.microsecondsSinceEpoch}-$randomPart';
  }
}
