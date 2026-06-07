import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../../core/sync/hive_sync_operation_queue.dart';
import '../../../core/sync/sync_operation_queue.dart';
import '../../queue/domain/saved_item.dart';
import '../data/hive_saved_item_repository.dart';
import '../domain/save_link.dart';
import '../domain/saved_item_repository.dart';

const guestOwnerId = 'guest-device';

final savedItemRepositoryProvider = FutureProvider<SavedItemRepository>((ref) async {
  final box = await AppStorage.openSavedItemsBox();
  return HiveSavedItemRepository(box: box);
});

final syncOperationQueueProvider = FutureProvider<SyncOperationQueue>((ref) async {
  final box = await AppStorage.openSyncOperationsBox();
  return HiveSyncOperationQueue(box: box);
});

final saveLinkProvider = FutureProvider<SaveLink>((ref) async {
  final repository = await ref.watch(savedItemRepositoryProvider.future);
  final syncQueue = await ref.watch(syncOperationQueueProvider.future);
  return SaveLink(repository: repository, syncQueue: syncQueue, now: DateTime.now);
});

final savedItemsProvider = StreamProvider<List<SavedItem>>((ref) async* {
  final repository = await ref.watch(savedItemRepositoryProvider.future);
  yield* repository.watchItems(ownerId: guestOwnerId);
});
