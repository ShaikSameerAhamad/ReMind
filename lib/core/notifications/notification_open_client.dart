final class NotificationPayload {
  const NotificationPayload(this.data);

  final Map<String, String> data;
}

abstract interface class NotificationOpenClient {
  Stream<NotificationPayload> get notificationOpens;

  Future<NotificationPayload?> initialNotification();
}
