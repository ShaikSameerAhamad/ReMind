import 'shared_alarm.dart';

abstract interface class AlarmRepository {
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId);

  Future<void> createAlarm(SharedAlarm alarm);
}
