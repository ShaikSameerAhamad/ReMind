import 'app_routes.dart';

final class DeepLinkParser {
  const DeepLinkParser();

  String? routeFor(Map<String, String> data) {
    final deepLink = data['deepLink'] ?? data['link'];
    if (deepLink != null && deepLink.trim().isNotEmpty) {
      return _routeFromUri(Uri.tryParse(deepLink.trim()));
    }

    return _routeFromType(data);
  }

  String? _routeFromUri(Uri? uri) {
    if (uri == null || uri.scheme != 'remind') {
      return null;
    }

    final segments = [
      if (uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments,
    ];
    return _routeFromSegments(segments);
  }

  String? _routeFromSegments(List<String> segments) {
    try {
      return switch (segments) {
        ['queues', final queueId] => AppRoutes.queue(queueId),
        ['groups', final groupId] => AppRoutes.groupDetail(groupId),
        ['groups', final groupId, 'invites', final inviteCode] =>
          AppRoutes.groupInvite(groupId, inviteCode),
        ['groups', final groupId, 'tasks', final taskId] =>
          AppRoutes.taskDetail(groupId, taskId),
        ['groups', final groupId, 'alarms', final alarmId] =>
          AppRoutes.alarmReceived(groupId, alarmId),
        ['groups', final groupId, 'alarms', final alarmId, 'received'] =>
          AppRoutes.alarmReceived(groupId, alarmId),
        _ => null,
      };
    } on ArgumentError {
      return null;
    }
  }

  String? _routeFromType(Map<String, String> data) {
    try {
      return switch (data['type']) {
        'daily_digest' ||
        'queue' =>
          AppRoutes.queue(data['queueId'] ?? 'recently-saved'),
        'group_invite' => _groupInviteRoute(data),
        'group_activity' => _groupRoute(data),
        'task_assigned' ||
        'task_updated' ||
        'task_completed' =>
          _taskRoute(data),
        'shared_alarm' || 'alarm_due' => _alarmRoute(data),
        _ => null,
      };
    } on ArgumentError {
      return null;
    }
  }

  String? _groupRoute(Map<String, String> data) {
    final groupId = data['groupId'];
    return groupId == null ? null : AppRoutes.groupDetail(groupId);
  }

  String? _groupInviteRoute(Map<String, String> data) {
    final groupId = data['groupId'];
    final inviteCode = data['inviteCode'] ?? data['code'];
    if (groupId == null) {
      return null;
    }
    return inviteCode == null
        ? AppRoutes.groupDetail(groupId)
        : AppRoutes.groupInvite(groupId, inviteCode);
  }

  String? _taskRoute(Map<String, String> data) {
    final groupId = data['groupId'];
    final taskId = data['taskId'];
    return groupId == null || taskId == null
        ? null
        : AppRoutes.taskDetail(groupId, taskId);
  }

  String? _alarmRoute(Map<String, String> data) {
    final groupId = data['groupId'];
    final alarmId = data['alarmId'];
    return groupId == null || alarmId == null
        ? null
        : AppRoutes.alarmReceived(groupId, alarmId);
  }
}
