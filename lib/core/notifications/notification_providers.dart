import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_bootstrap.dart';
import 'fcm_token_registrar.dart';
import 'firebase_push_messaging_client.dart';
import 'firestore_push_token_store.dart';
import 'push_messaging_client.dart';
import 'push_token_store.dart';

final pushMessagingClientProvider = FutureProvider<PushMessagingClient?>((ref) async {
  final firebase = await FirebaseBootstrap.ensureInitialized();
  if (!firebase.isConfigured) {
    return null;
  }
  return FirebasePushMessagingClient(messaging: FirebaseMessaging.instance);
});

final pushTokenStoreProvider = FutureProvider<PushTokenStore?>((ref) async {
  final firebase = await FirebaseBootstrap.ensureInitialized();
  if (!firebase.isConfigured) {
    return null;
  }
  return FirestorePushTokenStore(firestore: FirebaseFirestore.instance);
});

final fcmTokenRegistrarProvider = FutureProvider<FcmTokenRegistrar?>((ref) async {
  final messagingClient = await ref.watch(pushMessagingClientProvider.future);
  final tokenStore = await ref.watch(pushTokenStoreProvider.future);
  if (messagingClient == null || tokenStore == null) {
    return null;
  }
  return FcmTokenRegistrar(messagingClient: messagingClient, tokenStore: tokenStore);
});
