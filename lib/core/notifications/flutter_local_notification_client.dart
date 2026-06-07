import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_open_client.dart';

final class FlutterLocalNotificationClient implements NotificationOpenClient {
  FlutterLocalNotificationClient._();

  static final FlutterLocalNotificationClient instance =
      FlutterLocalNotificationClient._();

  static const alarmChannelId = 'remind_shared_alarms';
  static const _alarmChannelName = 'Shared alarms';
  static const _alarmChannelDescription =
      'Local fallback notifications for due shared alarms.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final _notificationOpens = StreamController<NotificationPayload>.broadcast();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    if (!_isAndroid) {
      _initialized = true;
      return;
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (!_isAndroid) {
      return;
    }
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showSharedAlarm({
    required String groupId,
    required String alarmId,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (!_isAndroid) {
      return;
    }
    await initialize();
    final payload = _payloadForAlarm(
      groupId: groupId,
      alarmId: alarmId,
      scheduledAt: scheduledAt,
    );
    await _plugin.show(
      id: _stableNotificationId('$groupId:$alarmId'),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          alarmChannelId,
          _alarmChannelName,
          channelDescription: _alarmChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          autoCancel: true,
          visibility: NotificationVisibility.public,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  @override
  Stream<NotificationPayload> get notificationOpens =>
      _notificationOpens.stream;

  @override
  Future<NotificationPayload?> initialNotification() async {
    if (!_isAndroid) {
      return null;
    }
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp != true || response == null) {
      return null;
    }
    return _payloadFromResponse(response);
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = _payloadFromResponse(response);
    if (payload != null) {
      _notificationOpens.add(payload);
    }
  }

  NotificationPayload? _payloadFromResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }
    Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      return null;
    }
    return decoded is Map
        ? NotificationPayload(
            decoded.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
        : null;
  }

  Map<String, String> _payloadForAlarm({
    required String groupId,
    required String alarmId,
    required DateTime scheduledAt,
  }) {
    return {
      'type': 'shared_alarm',
      'groupId': groupId,
      'alarmId': alarmId,
      'deepLink': 'remind://groups/$groupId/alarms/$alarmId/received',
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'source': 'local_alarm_fallback',
    };
  }

  int _stableNotificationId(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
