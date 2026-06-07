import 'shared_alarm.dart';

abstract interface class LocalAlarmFallbackScheduler {
  Future<void> initialize();

  Future<void> scheduleForUser({
    required SharedAlarm alarm,
    required String userId,
  });

  Future<void> syncForUser({
    required List<SharedAlarm> alarms,
    required String userId,
  });

  Future<void> cancel(SharedAlarm alarm);
}

final class NoopLocalAlarmFallbackScheduler
    implements LocalAlarmFallbackScheduler {
  const NoopLocalAlarmFallbackScheduler();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleForUser({
    required SharedAlarm alarm,
    required String userId,
  }) async {}

  @override
  Future<void> syncForUser({
    required List<SharedAlarm> alarms,
    required String userId,
  }) async {}

  @override
  Future<void> cancel(SharedAlarm alarm) async {}
}

bool shouldScheduleLocalAlarmFallback({
  required SharedAlarm alarm,
  required String userId,
  required DateTime now,
}) {
  return alarm.status == AlarmStatus.scheduled &&
      alarm.recipients.contains(userId) &&
      !alarm.isDismissedBy(userId) &&
      alarm.scheduledAt.isAfter(now.toUtc());
}

DateTime? nextLocalAlarmOccurrence({
  required DateTime scheduledAt,
  required AlarmRepeat repeat,
  required List<int> repeatDays,
  required DateTime after,
}) {
  if (repeat == AlarmRepeat.once) {
    return null;
  }

  final localAfter = after.toLocal();
  final localScheduledAt = scheduledAt.toLocal();
  DateTime atClock(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      localScheduledAt.hour,
      localScheduledAt.minute,
      localScheduledAt.second,
      localScheduledAt.millisecond,
      localScheduledAt.microsecond,
    );
  }

  if (repeat == AlarmRepeat.daily) {
    var candidate = atClock(localAfter);
    if (!candidate.isAfter(localAfter)) {
      candidate = atClock(localAfter.add(const Duration(days: 1)));
    }
    return candidate.toUtc();
  }

  final normalizedDays =
      repeatDays.where((day) => day >= 0 && day <= 6).toSet();
  if (normalizedDays.isEmpty) {
    return null;
  }
  for (var offset = 0; offset <= 7; offset += 1) {
    final day = localAfter.add(Duration(days: offset));
    final dartWeekday = day.weekday % 7;
    if (!normalizedDays.contains(dartWeekday)) {
      continue;
    }
    final candidate = atClock(day);
    if (candidate.isAfter(localAfter)) {
      return candidate.toUtc();
    }
  }
  return null;
}
