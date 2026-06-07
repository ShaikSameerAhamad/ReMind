import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';
import 'package:remind/features/alarms/domain/alarm_repository.dart';
import 'package:remind/features/alarms/domain/create_shared_alarm.dart';
import 'package:remind/features/alarms/domain/shared_alarm.dart';
import 'package:remind/features/auth/domain/auth_session.dart';

void main() {
  test('createSharedAlarm rejects guests before writing', () async {
    final repository = _RecordingAlarmRepository();
    final useCase = CreateSharedAlarm(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'alarm-1',
    );

    final result = await useCase(
      session: AuthSession.guest(deviceId: 'device-1'),
      groupId: 'family',
      title: 'Medicine',
      message: null,
      scheduledAt: DateTime.utc(2026, 6, 7, 11),
      localTimeZone: 'Asia/Kolkata',
      repeat: AlarmRepeat.once,
      repeatDays: const [],
      recipients: const ['uid-1'],
      validMemberIds: const {'uid-1'},
    );

    expect(
        result,
        const CreateSharedAlarmFailure(
            Invalid('Sign in to create shared alarms.')));
    expect(repository.createdAlarms, isEmpty);
  });

  test('createSharedAlarm validates title and recipients before writing',
      () async {
    final repository = _RecordingAlarmRepository();
    final useCase = CreateSharedAlarm(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'alarm-1',
    );

    final blankTitle = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      title: '',
      message: null,
      scheduledAt: DateTime.utc(2026, 6, 7, 11),
      localTimeZone: 'Asia/Kolkata',
      repeat: AlarmRepeat.once,
      repeatDays: const [],
      recipients: const ['uid-1'],
      validMemberIds: const {'uid-1'},
    );
    final missingRecipients = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      title: 'Medicine',
      message: null,
      scheduledAt: DateTime.utc(2026, 6, 7, 11),
      localTimeZone: 'Asia/Kolkata',
      repeat: AlarmRepeat.once,
      repeatDays: const [],
      recipients: const [],
      validMemberIds: const {'uid-1'},
    );

    expect(blankTitle,
        const CreateSharedAlarmFailure(Invalid('Alarm title is required.')));
    expect(
        missingRecipients,
        const CreateSharedAlarmFailure(
            Invalid('Choose at least one group member.')));
    expect(repository.createdAlarms, isEmpty);
  });

  test('createSharedAlarm validates future schedule and group membership',
      () async {
    final repository = _RecordingAlarmRepository();
    final useCase = CreateSharedAlarm(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'alarm-1',
    );

    final pastSchedule = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      title: 'Medicine',
      message: null,
      scheduledAt: DateTime.utc(2026, 6, 7, 9, 59),
      localTimeZone: 'Asia/Kolkata',
      repeat: AlarmRepeat.once,
      repeatDays: const [],
      recipients: const ['uid-1'],
      validMemberIds: const {'uid-1'},
    );
    final invalidRecipient = await useCase(
      session: _signedInSession(),
      groupId: 'family',
      title: 'Medicine',
      message: null,
      scheduledAt: DateTime.utc(2026, 6, 7, 11),
      localTimeZone: 'Asia/Kolkata',
      repeat: AlarmRepeat.once,
      repeatDays: const [],
      recipients: const ['uid-2'],
      validMemberIds: const {'uid-1'},
    );

    expect(pastSchedule,
        const CreateSharedAlarmFailure(Invalid('Choose a future alarm time.')));
    expect(
        invalidRecipient,
        const CreateSharedAlarmFailure(
            Invalid('Alarm recipients must be current group members.')));
    expect(repository.createdAlarms, isEmpty);
  });

  test('createSharedAlarm writes normalized alarm data', () async {
    final repository = _RecordingAlarmRepository();
    final useCase = CreateSharedAlarm(
      repository: repository,
      now: () => DateTime.utc(2026, 6, 7, 10),
      idGenerator: () => 'alarm-1',
    );

    final result = await useCase(
      session: _signedInSession(),
      groupId: ' family ',
      title: '  Medicine  ',
      message: '  Take after food  ',
      scheduledAt: DateTime.utc(2026, 6, 7, 11),
      localTimeZone: 'Asia/Kolkata',
      repeat: AlarmRepeat.daily,
      repeatDays: const [],
      recipients: const [' uid-1 ', 'uid-2'],
      validMemberIds: const {'uid-1', 'uid-2'},
    );

    expect(result, isA<CreateSharedAlarmSuccess>());
    final alarm = repository.createdAlarms.single;
    expect(alarm.id, 'alarm-1');
    expect(alarm.groupId, 'family');
    expect(alarm.title, 'Medicine');
    expect(alarm.message, 'Take after food');
    expect(alarm.createdBy, 'uid-1');
    expect(alarm.scheduledAt, DateTime.utc(2026, 6, 7, 11));
    expect(alarm.localTimeZone, 'Asia/Kolkata');
    expect(alarm.repeat, AlarmRepeat.daily);
    expect(alarm.recipients, ['uid-1', 'uid-2']);
    expect(alarm.status, AlarmStatus.scheduled);
    expect(alarm.createdAt, DateTime.utc(2026, 6, 7, 10));
    expect(alarm.updatedAt, DateTime.utc(2026, 6, 7, 10));
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
  final createdAlarms = <SharedAlarm>[];

  @override
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId) =>
      const Stream.empty();

  @override
  Stream<SharedAlarm?> watchAlarm({
    required String groupId,
    required String alarmId,
  }) =>
      const Stream.empty();

  @override
  Future<void> createAlarm(SharedAlarm alarm) async {
    createdAlarms.add(alarm);
  }

  @override
  Future<void> dismissAlarm(AlarmDismissal dismissal) async {}
}
