import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/alarms/domain/alarm_repository.dart';
import 'package:remind/features/alarms/domain/shared_alarm.dart';
import 'package:remind/features/alarms/presentation/alarm_providers.dart';
import 'package:remind/features/alarms/presentation/alarm_received_screen.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';

import '../../../support/recording_auth_repository.dart';

void main() {
  testWidgets('signed-in recipient dismisses received shared alarm',
      (tester) async {
    final authRepository = RecordingAuthRepository(
      initialSession: AuthSession.signedIn(
        profile: const AuthProfile(
          uid: 'uid-1',
          email: 'sameer@example.com',
          displayName: 'Sameer',
          avatarUrl: null,
        ),
      ),
    );
    final alarmRepository = _RecordingAlarmRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmRepositoryProvider.overrideWithValue(alarmRepository),
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: const MaterialApp(
          home: AlarmReceivedScreen(groupId: 'family', alarmId: 'alarm-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Medicine'), findsOneWidget);
    expect(find.text('Take after food'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(alarmRepository.dismissals.single.alarmId, 'alarm-1');
    expect(alarmRepository.dismissals.single.dismissedBy, 'uid-1');
    expect(find.text('Alarm dismissed.'), findsOneWidget);
  });
}

final class _RecordingAlarmRepository implements AlarmRepository {
  final dismissals = <AlarmDismissal>[];
  final _controller = StreamController<SharedAlarm?>.broadcast();
  late SharedAlarm _alarm = SharedAlarm(
    id: 'alarm-1',
    groupId: 'family',
    title: 'Medicine',
    message: 'Take after food',
    createdBy: 'uid-2',
    scheduledAt: DateTime.utc(2026, 6, 7, 11),
    localTimeZone: 'Asia/Kolkata',
    repeat: AlarmRepeat.once,
    repeatDays: const [],
    recipients: const ['uid-1'],
    status: AlarmStatus.sent,
    createdAt: DateTime.utc(2026, 6, 7, 10),
    updatedAt: DateTime.utc(2026, 6, 7, 10),
    lastTriggeredAt: DateTime.utc(2026, 6, 7, 11),
  );

  @override
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId) =>
      Stream.value([_alarm]);

  @override
  Stream<SharedAlarm?> watchAlarm({
    required String groupId,
    required String alarmId,
  }) async* {
    yield _alarm;
    yield* _controller.stream;
  }

  @override
  Future<void> createAlarm(SharedAlarm alarm) async {}

  @override
  Future<void> dismissAlarm(AlarmDismissal dismissal) async {
    dismissals.add(dismissal);
    _alarm = SharedAlarm(
      id: _alarm.id,
      groupId: _alarm.groupId,
      title: _alarm.title,
      message: _alarm.message,
      createdBy: _alarm.createdBy,
      scheduledAt: _alarm.scheduledAt,
      localTimeZone: _alarm.localTimeZone,
      repeat: _alarm.repeat,
      repeatDays: _alarm.repeatDays,
      recipients: _alarm.recipients,
      status: _alarm.status,
      createdAt: _alarm.createdAt,
      updatedAt: dismissal.dismissedAt,
      lastTriggeredAt: _alarm.lastTriggeredAt,
      dismissals: {
        ..._alarm.dismissals,
        dismissal.dismissedBy: dismissal.dismissedAt,
      },
    );
    _controller.add(_alarm);
  }
}
