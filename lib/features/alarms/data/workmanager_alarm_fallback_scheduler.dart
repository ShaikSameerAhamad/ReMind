import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/notifications/flutter_local_notification_client.dart';
import '../domain/local_alarm_fallback.dart';
import '../domain/shared_alarm.dart';

const sharedAlarmFallbackTaskName = 'remind.sharedAlarmFallback';
const sharedAlarmFallbackTag = 'remind.sharedAlarms';

final class WorkmanagerAlarmFallbackScheduler
    implements LocalAlarmFallbackScheduler {
  WorkmanagerAlarmFallbackScheduler({
    required Workmanager workmanager,
    required DateTime Function() now,
  })  : _workmanager = workmanager,
        _now = now;

  final Workmanager _workmanager;
  final DateTime Function() _now;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || !_canUseWorkmanager) {
      return;
    }
    await FlutterLocalNotificationClient.instance.initialize();
    await FlutterLocalNotificationClient.instance.requestPermission();
    await _workmanager.initialize(sharedAlarmFallbackCallbackDispatcher);
    _initialized = true;
  }

  @override
  Future<void> scheduleForUser({
    required SharedAlarm alarm,
    required String userId,
  }) async {
    if (!shouldScheduleLocalAlarmFallback(
      alarm: alarm,
      userId: userId,
      now: _now(),
    )) {
      await cancel(alarm);
      return;
    }
    await _register(alarm);
  }

  @override
  Future<void> syncForUser({
    required List<SharedAlarm> alarms,
    required String userId,
  }) async {
    for (final alarm in alarms) {
      if (shouldScheduleLocalAlarmFallback(
        alarm: alarm,
        userId: userId,
        now: _now(),
      )) {
        await _register(alarm);
      } else {
        await cancel(alarm);
      }
    }
  }

  @override
  Future<void> cancel(SharedAlarm alarm) {
    return _workmanager
        .cancelByUniqueName(_uniqueName(alarm.groupId, alarm.id));
  }

  Future<void> _register(SharedAlarm alarm) async {
    await initialize();
    final delay = alarm.scheduledAt.difference(_now().toUtc());
    await _workmanager.registerOneOffTask(
      _uniqueName(alarm.groupId, alarm.id),
      sharedAlarmFallbackTaskName,
      initialDelay: delay.isNegative ? Duration.zero : delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      tag: sharedAlarmFallbackTag,
      inputData: _inputDataForAlarm(alarm),
    );
  }
}

bool get _canUseWorkmanager {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

@pragma('vm:entry-point')
void sharedAlarmFallbackCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != sharedAlarmFallbackTaskName || inputData == null) {
      return true;
    }

    final alarm = _alarmInputFromData(inputData);
    if (alarm == null) {
      return true;
    }

    await FlutterLocalNotificationClient.instance.showSharedAlarm(
      groupId: alarm.groupId,
      alarmId: alarm.alarmId,
      title: alarm.title,
      body: alarm.message ?? 'Shared alarm due now.',
      scheduledAt: alarm.scheduledAt,
    );

    final next = nextLocalAlarmOccurrence(
      scheduledAt: alarm.scheduledAt,
      repeat: alarm.repeat,
      repeatDays: alarm.repeatDays,
      after: DateTime.now(),
    );
    if (next != null) {
      await Workmanager().registerOneOffTask(
        _uniqueName(alarm.groupId, alarm.alarmId),
        sharedAlarmFallbackTaskName,
        initialDelay: next.difference(DateTime.now().toUtc()),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: sharedAlarmFallbackTag,
        inputData: {
          ...inputData,
          'scheduledAtMillis': next.millisecondsSinceEpoch,
        },
      );
    }
    return true;
  });
}

Map<String, dynamic> _inputDataForAlarm(SharedAlarm alarm) {
  return {
    'groupId': alarm.groupId,
    'alarmId': alarm.id,
    'title': alarm.title,
    'message': alarm.message,
    'scheduledAtMillis': alarm.scheduledAt.toUtc().millisecondsSinceEpoch,
    'repeat': alarm.repeat.name,
    'repeatDays': alarm.repeatDays,
  };
}

String _uniqueName(String groupId, String alarmId) {
  return 'remind-shared-alarm-$groupId-$alarmId';
}

_AlarmInput? _alarmInputFromData(Map<String, dynamic> data) {
  final groupId = data['groupId'];
  final alarmId = data['alarmId'];
  final title = data['title'];
  final scheduledAtMillis = data['scheduledAtMillis'];
  if (groupId is! String ||
      alarmId is! String ||
      title is! String ||
      scheduledAtMillis is! int) {
    return null;
  }
  return _AlarmInput(
    groupId: groupId,
    alarmId: alarmId,
    title: title,
    message: data['message'] as String?,
    scheduledAt:
        DateTime.fromMillisecondsSinceEpoch(scheduledAtMillis, isUtc: true),
    repeat: _repeatFromName(data['repeat']),
    repeatDays: _repeatDaysFromData(data['repeatDays']),
  );
}

AlarmRepeat _repeatFromName(Object? value) {
  if (value is String) {
    for (final repeat in AlarmRepeat.values) {
      if (repeat.name == value) {
        return repeat;
      }
    }
  }
  return AlarmRepeat.once;
}

List<int> _repeatDaysFromData(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<int>().toList(growable: false);
}

final class _AlarmInput {
  const _AlarmInput({
    required this.groupId,
    required this.alarmId,
    required this.title,
    required this.scheduledAt,
    required this.repeat,
    required this.repeatDays,
    this.message,
  });

  final String groupId;
  final String alarmId;
  final String title;
  final String? message;
  final DateTime scheduledAt;
  final AlarmRepeat repeat;
  final List<int> repeatDays;
}
