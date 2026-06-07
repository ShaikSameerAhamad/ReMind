import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/sync/hive_sync_operation_queue.dart';
import '../../../core/sync/saved_item_remote_store.dart';
import '../../../core/sync/saved_item_sync_engine.dart';
import '../../../core/sync/sync_operation_queue.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../queue/domain/saved_item.dart';
import '../data/firestore_saved_item_remote_store.dart';
import '../data/hive_saved_item_repository.dart';
import '../domain/save_link.dart';
import '../domain/saved_item_repository.dart';

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

final savedItemRemoteStoreProvider = FutureProvider<SavedItemRemoteStore?>((ref) async {
  final firebase = await FirebaseBootstrap.ensureInitialized();
  if (!firebase.isConfigured) {
    return null;
  }
  return FirestoreSavedItemRemoteStore(firestore: FirebaseFirestore.instance);
});

final savedItemSyncEngineProvider = FutureProvider<SavedItemSyncEngine?>((ref) async {
  final remoteStore = await ref.watch(savedItemRemoteStoreProvider.future);
  if (remoteStore == null) {
    return null;
  }
  final queue = await ref.watch(syncOperationQueueProvider.future);
  final repository = await ref.watch(savedItemRepositoryProvider.future);
  return SavedItemSyncEngine(
    queue: queue,
    remoteStore: remoteStore,
    localRepository: repository,
  );
});

final savedItemsProvider = StreamProvider<List<SavedItem>>((ref) async* {
  final repository = await ref.watch(savedItemRepositoryProvider.future);
  final ownerId = await ref.watch(authOwnerIdProvider.future);
  if (ownerId == null) {
    yield const <SavedItem>[];
    return;
  }
  yield* repository.watchItems(ownerId: ownerId);
});
