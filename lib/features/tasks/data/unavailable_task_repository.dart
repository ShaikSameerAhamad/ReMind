import '../domain/group_task.dart';
import '../domain/task_repository.dart';

final class UnavailableTaskRepository implements TaskRepository {
  const UnavailableTaskRepository();

  @override
  Stream<List<GroupTask>> watchGroupTasks(String groupId) =>
      const Stream.empty();

  @override
  Stream<GroupTask?> watchTask({
    required String groupId,
    required String taskId,
  }) {
    return const Stream.empty();
  }

  @override
  Future<void> createTask(GroupTask task) {
    throw StateError(
        'Firebase is not configured yet. Add google-services.json before creating shared tasks.');
  }

  @override
  Future<void> completeTask(GroupTaskCompletion completion) {
    throw StateError(
        'Firebase is not configured yet. Add google-services.json before completing shared tasks.');
  }
}
