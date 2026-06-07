import '../domain/alarm_repository.dart';
import '../domain/shared_alarm.dart';

final class UnavailableAlarmRepository implements AlarmRepository {
  const UnavailableAlarmRepository();

  @override
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId) =>
      const Stream.empty();

  @override
  Stream<SharedAlarm?> watchAlarm({
    required String groupId,
    required String alarmId,
  }) {
    return const Stream.empty();
  }

  @override
  Future<void> createAlarm(SharedAlarm alarm) {
    throw StateError(
        'Firebase is not configured yet. Add google-services.json before creating shared alarms.');
  }

  @override
  Future<void> dismissAlarm(AlarmDismissal dismissal) {
    throw StateError(
        'Firebase is not configured yet. Add google-services.json before dismissing shared alarms.');
  }
}
