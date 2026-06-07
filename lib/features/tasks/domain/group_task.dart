enum GroupTaskPriority { low, normal, high }

enum GroupTaskStatus { open, completed }

final class GroupTask {
  const GroupTask({
    required this.id,
    required this.groupId,
    required this.title,
    required this.createdBy,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.assignedTo,
    this.dueAt,
    this.completedAt,
    this.completedBy,
  });

  final String id;
  final String groupId;
  final String title;
  final String? notes;
  final String createdBy;
  final String? assignedTo;
  final GroupTaskPriority priority;
  final GroupTaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final String? completedBy;

  bool get isCompleted => status == GroupTaskStatus.completed;
}

final class GroupTaskCompletion {
  const GroupTaskCompletion({
    required this.groupId,
    required this.taskId,
    required this.completedBy,
    required this.completedAt,
  });

  final String groupId;
  final String taskId;
  final String completedBy;
  final DateTime completedAt;
}
