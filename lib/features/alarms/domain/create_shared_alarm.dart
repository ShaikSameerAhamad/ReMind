import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import 'alarm_repository.dart';
import 'shared_alarm.dart';

sealed class CreateSharedAlarmResult {
  const CreateSharedAlarmResult();
}

final class CreateSharedAlarmSuccess extends CreateSharedAlarmResult {
  const CreateSharedAlarmSuccess(this.alarm);

  final SharedAlarm alarm;
}

final class CreateSharedAlarmFailure extends CreateSharedAlarmResult {
  const CreateSharedAlarmFailure(this.reason);

  final ValidationResult reason;

  @override
  bool operator ==(Object other) {
    return other is CreateSharedAlarmFailure && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class CreateSharedAlarm {
  const CreateSharedAlarm({
    required AlarmRepository repository,
    required DateTime Function() now,
    required String Function() idGenerator,
  })  : _repository = repository,
        _now = now,
        _idGenerator = idGenerator;

  final AlarmRepository _repository;
  final DateTime Function() _now;
  final String Function() _idGenerator;

  Future<CreateSharedAlarmResult> call({
    required AuthSession session,
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
    if (!session.canUseCloud || session.profile == null) {
      return const CreateSharedAlarmFailure(
          Invalid('Sign in to create shared alarms.'));
    }

    final trimmedGroupId = groupId.trim();
    if (trimmedGroupId.isEmpty) {
      return const CreateSharedAlarmFailure(Invalid('Group is required.'));
    }
    if (trimmedGroupId.contains('/')) {
      return const CreateSharedAlarmFailure(Invalid('Group is invalid.'));
    }

    final titleValidation = _alarmTitle(title);
    if (titleValidation is Invalid) {
      return CreateSharedAlarmFailure(titleValidation);
    }

    final normalizedRecipients = _normalizeRecipients(recipients);
    final recipientValidation =
        ReMindValidators.alarmRecipients(normalizedRecipients);
    if (recipientValidation is Invalid) {
      return CreateSharedAlarmFailure(recipientValidation);
    }
    if (normalizedRecipients
        .any((recipient) => !validMemberIds.contains(recipient))) {
      return const CreateSharedAlarmFailure(
          Invalid('Alarm recipients must be current group members.'));
    }

    final timestamp = _now().toUtc();
    final alarmTime = scheduledAt.toUtc();
    if (!alarmTime.isAfter(timestamp)) {
      return const CreateSharedAlarmFailure(
          Invalid('Choose a future alarm time.'));
    }

    final normalizedRepeatDays = repeat == AlarmRepeat.weekly
        ? _normalizeRepeatDays(repeatDays)
        : const <int>[];
    if (repeat == AlarmRepeat.weekly && normalizedRepeatDays.isEmpty) {
      return const CreateSharedAlarmFailure(
          Invalid('Choose at least one repeat day.'));
    }

    final alarm = SharedAlarm(
      id: _idGenerator(),
      groupId: trimmedGroupId,
      title: title.trim(),
      message: _optionalText(message),
      createdBy: session.profile!.uid,
      scheduledAt: alarmTime,
      localTimeZone:
          localTimeZone.trim().isEmpty ? 'UTC' : localTimeZone.trim(),
      repeat: repeat,
      repeatDays: normalizedRepeatDays,
      recipients: normalizedRecipients,
      status: AlarmStatus.scheduled,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    await _repository.createAlarm(alarm);
    return CreateSharedAlarmSuccess(alarm);
  }

  ValidationResult _alarmTitle(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const Invalid('Alarm title is required.');
    }
    if (trimmed.length > 120) {
      return const Invalid('Alarm title must be 120 characters or less.');
    }
    return const Valid();
  }

  List<String> _normalizeRecipients(List<String> recipients) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final recipient in recipients) {
      final trimmed = recipient.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) {
        continue;
      }
      seen.add(trimmed);
      normalized.add(trimmed);
    }
    return normalized;
  }

  List<int> _normalizeRepeatDays(List<int> repeatDays) {
    final values =
        repeatDays.where((day) => day >= 0 && day <= 6).toSet().toList();
    values.sort();
    return values;
  }

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
