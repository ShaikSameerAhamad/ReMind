import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/alarms/domain/local_alarm_fallback.dart';
import 'package:remind/features/alarms/domain/shared_alarm.dart';

void main() {
  group('shouldScheduleLocalAlarmFallback', () {
    final now = DateTime.utc(2026, 6, 7, 10);

    test('schedules future alarms for the current recipient', () {
      final alarm = _alarm(
        scheduledAt: now.add(const Duration(minutes: 30)),
        recipients: const ['alice'],
      );

      expect(
        shouldScheduleLocalAlarmFallback(
          alarm: alarm,
          userId: 'alice',
          now: now,
        ),
        isTrue,
      );
    });

    test('does not schedule dismissed, past, sent, or non-recipient alarms',
        () {
      final future = now.add(const Duration(minutes: 30));

      expect(
        shouldScheduleLocalAlarmFallback(
          alarm: _alarm(
            scheduledAt: future,
            recipients: const ['alice'],
            dismissals: {'alice': now},
          ),
          userId: 'alice',
          now: now,
        ),
        isFalse,
      );
      expect(
        shouldScheduleLocalAlarmFallback(
          alarm: _alarm(
            scheduledAt: now.subtract(const Duration(minutes: 1)),
            recipients: const ['alice'],
          ),
          userId: 'alice',
          now: now,
        ),
        isFalse,
      );
      expect(
        shouldScheduleLocalAlarmFallback(
          alarm: _alarm(
            scheduledAt: future,
            recipients: const ['alice'],
            status: AlarmStatus.sent,
          ),
          userId: 'alice',
          now: now,
        ),
        isFalse,
      );
      expect(
        shouldScheduleLocalAlarmFallback(
          alarm: _alarm(
            scheduledAt: future,
            recipients: const ['bob'],
          ),
          userId: 'alice',
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('nextLocalAlarmOccurrence', () {
    test('does not reschedule one-time alarms', () {
      expect(
        nextLocalAlarmOccurrence(
          scheduledAt: DateTime.utc(2026, 6, 7, 8, 30),
          repeat: AlarmRepeat.once,
          repeatDays: const [],
          after: DateTime.utc(2026, 6, 7, 8, 31),
        ),
        isNull,
      );
    });

    test('advances daily alarms to the next wall-clock time', () {
      final next = nextLocalAlarmOccurrence(
        scheduledAt: DateTime.utc(2026, 6, 7, 8, 30),
        repeat: AlarmRepeat.daily,
        repeatDays: const [],
        after: DateTime.utc(2026, 6, 7, 8, 31),
      );

      expect(next, DateTime.utc(2026, 6, 8, 8, 30));
    });

    test('advances weekly alarms to the next selected weekday', () {
      final next = nextLocalAlarmOccurrence(
        scheduledAt: DateTime.utc(2026, 6, 7, 8, 30),
        repeat: AlarmRepeat.weekly,
        repeatDays: const [1, 3],
        after: DateTime.utc(2026, 6, 7, 9),
      );

      expect(next, DateTime.utc(2026, 6, 8, 8, 30));
    });
  });
}

SharedAlarm _alarm({
  required DateTime scheduledAt,
  required List<String> recipients,
  AlarmStatus status = AlarmStatus.scheduled,
  Map<String, DateTime> dismissals = const {},
}) {
  return SharedAlarm(
    id: 'alarm-1',
    groupId: 'group-1',
    title: 'Leave home',
    createdBy: 'alice',
    scheduledAt: scheduledAt,
    localTimeZone: 'UTC',
    repeat: AlarmRepeat.once,
    repeatDays: const [],
    recipients: recipients,
    status: status,
    createdAt: DateTime.utc(2026, 6, 7, 9),
    updatedAt: DateTime.utc(2026, 6, 7, 9),
    dismissals: dismissals,
  );
}
