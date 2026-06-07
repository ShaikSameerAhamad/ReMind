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
}
