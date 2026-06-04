abstract final class AppRoutes {
  static const home = '/';
  static const auth = '/auth';
  static const save = '/save';
  static const groups = '/groups';
  static const settings = '/settings';
  static const queuePattern = '/queues/:queueId';
  static const groupDetailPattern = '/groups/:groupId';
  static const taskDetailPattern = '/groups/:groupId/tasks/:taskId';
  static const alarmReceivedPattern = '/groups/:groupId/alarms/:alarmId/received';

  static String queue(String queueId) => '/queues/${_segment(queueId, 'queueId')}';

  static String groupDetail(String groupId) => '/groups/${_segment(groupId, 'groupId')}';

  static String taskDetail(String groupId, String taskId) {
    return '/groups/${_segment(groupId, 'groupId')}/tasks/${_segment(taskId, 'taskId')}';
  }

  static String alarmReceived(String groupId, String alarmId) {
    return '/groups/${_segment(groupId, 'groupId')}/alarms/${_segment(alarmId, 'alarmId')}/received';
  }

  static String _segment(String value, String name) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('$name is required.');
    }
    if (trimmed.contains('/')) {
      throw ArgumentError('$name cannot contain "/".');
    }
    return Uri.encodeComponent(trimmed);
  }
}
