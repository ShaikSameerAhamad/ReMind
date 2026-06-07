import 'const_stream.dart';
import 'notification_open_client.dart';

final class EmptyNotificationOpenClient implements NotificationOpenClient {
  const EmptyNotificationOpenClient();

  @override
  Stream<NotificationPayload> get notificationOpens => constStream();

  @override
  Future<NotificationPayload?> initialNotification() async => null;
}
