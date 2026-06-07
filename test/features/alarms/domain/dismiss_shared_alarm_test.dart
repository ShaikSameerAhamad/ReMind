import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/alarms/domain/alarm_repository.dart';
import 'package:remind/features/alarms/domain/dismiss_shared_alarm.dart';
import 'package:remind/features/alarms/domain/shared_alarm.dart';
import 'package:remind/features/auth/domain/auth_session.dart';

void main() {
  test('dismissSharedAlarm rejects guests before writing', () async {
    final repository = _RecordingAlarmRepository();
    final useCase = DismissSharedAlarm(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: AuthSession.guest(deviceId: 'device-1'),
      groupId: 'family',
      alarmId: 'alarm-1',
    );

    expect(
        result,
        const DismissSharedAlarmFailure(
            Invalid('Sign in to dismiss shared alarms.')));
    expect(repository.dismissals, isEmpty);
  });

  test('dismissSharedAlarm validates route segments before writing', () async {
    final repository = _RecordingAlarmRepository();
    final useCase = DismissSharedAlarm(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: 'family/private',
      alarmId: 'alarm-1',
    );

    expect(
        result, const DismissSharedAlarmFailure(Invalid('Alarm is invalid.')));
    expect(repository.dismissals, isEmpty);
  });

  test('dismissSharedAlarm writes current user dismissal metadata', () async {
    final repository = _RecordingAlarmRepository();
    final useCase = DismissSharedAlarm(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: ' family ',
      alarmId: ' alarm-1 ',
    );

    expect(result, const DismissSharedAlarmSuccess('alarm-1'));
    final dismissal = repository.dismissals.single;
    expect(dismissal.groupId, 'family');
    expect(dismissal.alarmId, 'alarm-1');
    expect(dismissal.dismissedBy, 'uid-1');
    expect(dismissal.dismissedAt, DateTime.utc(2026, 6, 7, 10));
  });
}

AuthSession _signedInSession() {
  return AuthSession.signedIn(
    profile: const AuthProfile(
      uid: 'uid-1',
      email: 'sameer@example.com',
      displayName: 'Sameer',
      avatarUrl: null,
    ),
  );
}

final class _RecordingAlarmRepository implements AlarmRepository {
  final dismissals = <AlarmDismissal>[];

  @override
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId) =>
      const Stream.empty();

  @override
  Stream<SharedAlarm?> watchAlarm(
          {required String groupId, required String alarmId}) =>
      const Stream.empty();

  @override
  Future<void> createAlarm(SharedAlarm alarm) async {}

  @override
  Future<void> dismissAlarm(AlarmDismissal dismissal) async {
    dismissals.add(dismissal);
  }
}
