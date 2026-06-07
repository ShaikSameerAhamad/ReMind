import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/unavailable_alarm_repository.dart';
import '../domain/alarm_repository.dart';
import '../domain/create_shared_alarm.dart';
import '../domain/dismiss_shared_alarm.dart';
import '../domain/local_alarm_fallback.dart';
import '../domain/shared_alarm.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return const UnavailableAlarmRepository();
});

final groupAlarmsProvider =
    StreamProvider.family<List<SharedAlarm>, String>((ref, groupId) {
  return ref.watch(alarmRepositoryProvider).watchGroupAlarms(groupId);
});

final sharedAlarmProvider =
    StreamProvider.family<SharedAlarm?, ({String groupId, String alarmId})>(
        (ref, args) {
  return ref
      .watch(alarmRepositoryProvider)
      .watchAlarm(groupId: args.groupId, alarmId: args.alarmId);
});

final createSharedAlarmProvider = Provider<CreateSharedAlarm>((ref) {
  return CreateSharedAlarm(
    repository: ref.watch(alarmRepositoryProvider),
    now: DateTime.now,
    idGenerator: _newAlarmId,
  );
});

final dismissSharedAlarmProvider = Provider<DismissSharedAlarm>((ref) {
  return DismissSharedAlarm(
    repository: ref.watch(alarmRepositoryProvider),
    now: DateTime.now,
  );
});

final localAlarmFallbackSchedulerProvider =
    Provider<LocalAlarmFallbackScheduler>((ref) {
  return const NoopLocalAlarmFallbackScheduler();
});

final localAlarmFallbackSyncProvider =
    Provider.family<void, String>((ref, groupId) {
  final sessionState = ref.watch(authControllerProvider);
  final alarmsState = ref.watch(groupAlarmsProvider(groupId));
  final session = sessionState.value;
  final alarms = alarmsState.value;
  final userId = session?.profile?.uid;
  if (userId == null || alarms == null) {
    return;
  }
  Future.microtask(() {
    ref.read(localAlarmFallbackSchedulerProvider).syncForUser(
          alarms: alarms,
          userId: userId,
        );
  });
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
    if (result case CreateSharedAlarmSuccess(:final alarm)) {
      final userId = session.profile?.uid;
      if (userId != null) {
        await ref.read(localAlarmFallbackSchedulerProvider).scheduleForUser(
              alarm: alarm,
              userId: userId,
            );
      }
    }
    return result;
  }
}

final alarmDismissalControllerProvider =
    AsyncNotifierProvider<AlarmDismissalController, String?>(
        AlarmDismissalController.new);

final class AlarmDismissalController extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<DismissSharedAlarmResult> dismiss({
    required String groupId,
    required String alarmId,
  }) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result = await ref.read(dismissSharedAlarmProvider)(
      session: session,
      groupId: groupId,
      alarmId: alarmId,
    );
    state = switch (result) {
      DismissSharedAlarmSuccess(:final alarmId) => AsyncData(alarmId),
      DismissSharedAlarmFailure() => const AsyncData(null),
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
