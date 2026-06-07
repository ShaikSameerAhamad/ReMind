import 'package:firebase_messaging/firebase_messaging.dart';

import 'push_messaging_client.dart';

final class FirebasePushMessagingClient implements PushMessagingClient {
  const FirebasePushMessagingClient({required FirebaseMessaging messaging}) : _messaging = messaging;

  final FirebaseMessaging _messaging;

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Future<void> deleteToken() {
    return _messaging.deleteToken();
  }

  @override
  Future<String?> getToken() {
    return _messaging.getToken();
  }

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }
}
