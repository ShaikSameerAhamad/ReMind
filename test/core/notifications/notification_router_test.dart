import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/notifications/notification_open_client.dart';
import 'package:remind/core/notifications/notification_router.dart';
import 'package:remind/core/routing/app_routes.dart';
import 'package:remind/core/routing/deep_link_parser.dart';

void main() {
  test('start routes initial notification payload', () async {
    const opened = _RecordingNotificationOpenClient(
      initialPayload: NotificationPayload({'deepLink': 'remind://queues/tonight'}),
    );
    final navigated = <String>[];
    final router = NotificationRouter(
      openClient: opened,
      parser: const DeepLinkParser(),
      navigate: navigated.add,
    );

    final subscription = await router.start();
    await subscription.cancel();

    expect(navigated, [AppRoutes.queue('tonight')]);
  });

  test('start routes notification open stream and ignores invalid payloads', () async {
    final controller = StreamController<NotificationPayload>();
    final opened = _RecordingNotificationOpenClient(openedPayloads: controller.stream);
    final navigated = <String>[];
    final router = NotificationRouter(
      openClient: opened,
      parser: const DeepLinkParser(),
      navigate: navigated.add,
    );

    final subscription = await router.start();
    controller.add(const NotificationPayload({'deepLink': 'https://example.com'}));
    controller.add(const NotificationPayload({'type': 'group_invite', 'groupId': 'family'}));
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    await controller.close();

    expect(navigated, [AppRoutes.groupDetail('family')]);
  });
}

final class _RecordingNotificationOpenClient implements NotificationOpenClient {
  const _RecordingNotificationOpenClient({
    this.initialPayload,
    this.openedPayloads = const Stream.empty(),
  });

  final NotificationPayload? initialPayload;
  final Stream<NotificationPayload> openedPayloads;

  @override
  Stream<NotificationPayload> get notificationOpens => openedPayloads;

  @override
  Future<NotificationPayload?> initialNotification() async => initialPayload;
}
