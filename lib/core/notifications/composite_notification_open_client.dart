import 'dart:async';

import 'notification_open_client.dart';

final class CompositeNotificationOpenClient implements NotificationOpenClient {
  const CompositeNotificationOpenClient(this._clients);

  final List<NotificationOpenClient> _clients;

  @override
  Stream<NotificationPayload> get notificationOpens {
    final controller = StreamController<NotificationPayload>.broadcast();
    final subscriptions = <StreamSubscription<NotificationPayload>>[];
    controller.onListen = () {
      for (final client in _clients) {
        subscriptions.add(client.notificationOpens.listen(controller.add));
      }
    };
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      subscriptions.clear();
    };
    return controller.stream;
  }

  @override
  Future<NotificationPayload?> initialNotification() async {
    for (final client in _clients) {
      final payload = await client.initialNotification();
      if (payload != null) {
        return payload;
      }
    }
    return null;
  }
}
