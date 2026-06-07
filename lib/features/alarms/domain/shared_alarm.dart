enum AlarmRepeat { once, daily, weekly }

enum AlarmStatus { scheduled, sent, completed, cancelled }

final class SharedAlarm {
  const SharedAlarm({
    required this.id,
    required this.groupId,
    required this.title,
    required this.createdBy,
    required this.scheduledAt,
    required this.localTimeZone,
    required this.repeat,
    required this.repeatDays,
    required this.recipients,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.message,
    this.lastTriggeredAt,
    this.dismissals = const {},
  });

  final String id;
  final String groupId;
  final String title;
  final String? message;
  final String createdBy;
  final DateTime scheduledAt;
  final String localTimeZone;
  final AlarmRepeat repeat;
  final List<int> repeatDays;
  final List<String> recipients;
  final AlarmStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastTriggeredAt;
  final Map<String, DateTime> dismissals;

  bool isDismissedBy(String userId) => dismissals.containsKey(userId);
}

final class AlarmDismissal {
  const AlarmDismissal({
    required this.groupId,
    required this.alarmId,
    required this.dismissedBy,
    required this.dismissedAt,
  });

  final String groupId;
  final String alarmId;
  final String dismissedBy;
  final DateTime dismissedAt;
}
