import 'shared_alarm.dart';

abstract interface class AlarmRepository {
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId);

  Stream<SharedAlarm?> watchAlarm({
    required String groupId,
    required String alarmId,
  });

  Future<void> createAlarm(SharedAlarm alarm);

  Future<void> dismissAlarm(AlarmDismissal dismissal);
}
