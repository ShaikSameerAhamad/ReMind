import 'group_task.dart';

abstract interface class TaskRepository {
  Stream<List<GroupTask>> watchGroupTasks(String groupId);

  Stream<GroupTask?> watchTask({
    required String groupId,
    required String taskId,
  });

  Future<void> createTask(GroupTask task);

  Future<void> completeTask(GroupTaskCompletion completion);

  Future<void> addComment(TaskComment comment);
}
