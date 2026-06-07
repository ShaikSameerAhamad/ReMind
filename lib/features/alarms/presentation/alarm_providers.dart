import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/unavailable_alarm_repository.dart';
import '../domain/alarm_repository.dart';
import '../domain/create_shared_alarm.dart';
import '../domain/shared_alarm.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return const UnavailableAlarmRepository();
});

final groupAlarmsProvider =
    StreamProvider.family<List<SharedAlarm>, String>((ref, groupId) {
  return ref.watch(alarmRepositoryProvider).watchGroupAlarms(groupId);
});

final createSharedAlarmProvider = Provider<CreateSharedAlarm>((ref) {
  return CreateSharedAlarm(
    repository: ref.watch(alarmRepositoryProvider),
    now: DateTime.now,
    idGenerator: _newAlarmId,
  );
});

final alarmCreationControllerProvider =
    AsyncNotifierProvider<AlarmCreationController, SharedAlarm?>(
        AlarmCreationController.new);

final class AlarmCreationController extends AsyncNotifier<SharedAlarm?> {
  @override
  SharedAlarm? build() => null;

  Future<CreateSharedAlarmResult> create({
    required String groupId,
    required String title,
    required String? message,
    required DateTime scheduledAt,
    required String localTimeZone,
    required AlarmRepeat repeat,
    required List<int> repeatDays,
    required List<String> recipients,
    required Set<String> validMemberIds,
  }) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result = await ref.read(createSharedAlarmProvider)(
      session: session,
      groupId: groupId,
      title: title,
      message: message,
      scheduledAt: scheduledAt,
      localTimeZone: localTimeZone,
      repeat: repeat,
      repeatDays: repeatDays,
      recipients: recipients,
      validMemberIds: validMemberIds,
    );
    state = switch (result) {
      CreateSharedAlarmSuccess(:final alarm) => AsyncData(alarm),
      CreateSharedAlarmFailure() => const AsyncData(null),
    };
    return result;
  }
}

String _newAlarmId() {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure();
  final suffix =
      List.generate(6, (_) => random.nextInt(36).toRadixString(36)).join();
  return 'alarm-$timestamp-$suffix';
}
