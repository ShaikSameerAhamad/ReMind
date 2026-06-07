import 'dart:async';

import '../routing/deep_link_parser.dart';
import 'notification_open_client.dart';

final class NotificationRouter {
  const NotificationRouter({
    required NotificationOpenClient openClient,
    required DeepLinkParser parser,
    required void Function(String route) navigate,
  })  : _openClient = openClient,
        _parser = parser,
        _navigate = navigate;

  final NotificationOpenClient _openClient;
  final DeepLinkParser _parser;
  final void Function(String route) _navigate;

  Future<StreamSubscription<NotificationPayload>> start() async {
    final initialPayload = await _openClient.initialNotification();
    if (initialPayload != null) {
      _route(initialPayload);
    }

    return _openClient.notificationOpens.listen(_route);
  }

  void _route(NotificationPayload payload) {
    final route = _parser.routeFor(payload.data);
    if (route == null) {
      return;
    }
    _navigate(route);
  }
}
