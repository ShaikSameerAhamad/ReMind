import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_bootstrap.dart';
import '../routing/deep_link_parser.dart';
import 'composite_notification_open_client.dart';
import 'empty_notification_open_client.dart';
import 'fcm_token_registrar.dart';
import 'firebase_notification_open_client.dart';
import 'firebase_push_messaging_client.dart';
import 'firestore_push_token_store.dart';
import 'notification_open_client.dart';
import 'notification_router.dart';
import 'push_messaging_client.dart';
import 'push_token_store.dart';

final pushMessagingClientProvider =
    FutureProvider<PushMessagingClient?>((ref) async {
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

final fcmTokenRegistrarProvider =
    FutureProvider<FcmTokenRegistrar?>((ref) async {
  final messagingClient = await ref.watch(pushMessagingClientProvider.future);
  final tokenStore = await ref.watch(pushTokenStoreProvider.future);
  if (messagingClient == null || tokenStore == null) {
    return null;
  }
  return FcmTokenRegistrar(
      messagingClient: messagingClient, tokenStore: tokenStore);
});

final notificationOpenClientProvider =
    FutureProvider<NotificationOpenClient?>((ref) async {
  final clients = <NotificationOpenClient>[
    ref.watch(localNotificationOpenClientProvider),
  ];
  final firebase = await FirebaseBootstrap.ensureInitialized();
  if (firebase.isConfigured) {
    clients.add(
        FirebaseNotificationOpenClient(messaging: FirebaseMessaging.instance));
  }
  return CompositeNotificationOpenClient(clients);
});

final localNotificationOpenClientProvider =
    Provider<NotificationOpenClient>((ref) {
  return const EmptyNotificationOpenClient();
});

final deepLinkParserProvider = Provider<DeepLinkParser>((ref) {
  return const DeepLinkParser();
});

final notificationRouterProvider =
    FutureProvider.family<NotificationRouter?, void Function(String route)>(
        (ref, navigate) async {
  final openClient = await ref.watch(notificationOpenClientProvider.future);
  if (openClient == null) {
    return null;
  }
  return NotificationRouter(
    openClient: openClient,
    parser: ref.watch(deepLinkParserProvider),
    navigate: navigate,
  );
});
