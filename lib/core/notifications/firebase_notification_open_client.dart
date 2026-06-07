import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_open_client.dart';

final class FirebaseNotificationOpenClient implements NotificationOpenClient {
  const FirebaseNotificationOpenClient({required FirebaseMessaging messaging}) : _messaging = messaging;

  final FirebaseMessaging _messaging;

  @override
  Stream<NotificationPayload> get notificationOpens {
    return FirebaseMessaging.onMessageOpenedApp.map(_payloadFromMessage);
  }

  @override
  Future<NotificationPayload?> initialNotification() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _payloadFromMessage(message);
  }

  NotificationPayload _payloadFromMessage(RemoteMessage message) {
    return NotificationPayload(
      message.data.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
