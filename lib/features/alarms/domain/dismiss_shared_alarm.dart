import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'alarm_repository.dart';
import 'shared_alarm.dart';

sealed class DismissSharedAlarmResult {
  const DismissSharedAlarmResult();
}

final class DismissSharedAlarmSuccess extends DismissSharedAlarmResult {
  const DismissSharedAlarmSuccess(this.alarmId);

  final String alarmId;

  @override
  bool operator ==(Object other) {
    return other is DismissSharedAlarmSuccess && other.alarmId == alarmId;
  }

  @override
  int get hashCode => alarmId.hashCode;
}

final class DismissSharedAlarmFailure extends DismissSharedAlarmResult {
  const DismissSharedAlarmFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is DismissSharedAlarmFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class DismissSharedAlarm {
  const DismissSharedAlarm({
    required AlarmRepository repository,
    required DateTime Function() now,
  })  : _repository = repository,
        _now = now;

  final AlarmRepository _repository;
  final DateTime Function() _now;

  Future<DismissSharedAlarmResult> call({
    required AuthSession session,
    required String groupId,
    required String alarmId,
  }) async {
    if (!session.canUseCloud || session.profile == null) {
      return const DismissSharedAlarmFailure(
          Invalid('Sign in to dismiss shared alarms.'));
    }

    final trimmedGroupId = groupId.trim();
    final trimmedAlarmId = alarmId.trim();
    if (trimmedGroupId.isEmpty || trimmedAlarmId.isEmpty) {
      return const DismissSharedAlarmFailure(Invalid('Alarm is required.'));
    }
    if (trimmedGroupId.contains('/') || trimmedAlarmId.contains('/')) {
      return const DismissSharedAlarmFailure(Invalid('Alarm is invalid.'));
    }

    await _repository.dismissAlarm(
      AlarmDismissal(
        groupId: trimmedGroupId,
        alarmId: trimmedAlarmId,
        dismissedBy: session.profile!.uid,
        dismissedAt: _now().toUtc(),
      ),
    );
    return DismissSharedAlarmSuccess(trimmedAlarmId);
  }
}
