import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/unavailable_task_repository.dart';
import '../domain/complete_group_task.dart';
import '../domain/create_group_task.dart';
import '../domain/group_task.dart';
import '../domain/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return const UnavailableTaskRepository();
});

final groupTasksProvider =
    StreamProvider.family<List<GroupTask>, String>((ref, groupId) {
  return ref.watch(taskRepositoryProvider).watchGroupTasks(groupId);
});

final groupTaskProvider =
    StreamProvider.family<GroupTask?, ({String groupId, String taskId})>(
        (ref, args) {
  return ref
      .watch(taskRepositoryProvider)
      .watchTask(groupId: args.groupId, taskId: args.taskId);
});

final createGroupTaskProvider = Provider<CreateGroupTask>((ref) {
  return CreateGroupTask(
    repository: ref.watch(taskRepositoryProvider),
    now: DateTime.now,
    idGenerator: _newTaskId,
  );
});

final completeGroupTaskProvider = Provider<CompleteGroupTask>((ref) {
  return CompleteGroupTask(
    repository: ref.watch(taskRepositoryProvider),
    now: DateTime.now,
  );
});

final taskCreationControllerProvider =
    AsyncNotifierProvider<TaskCreationController, GroupTask?>(
        TaskCreationController.new);

final class TaskCreationController extends AsyncNotifier<GroupTask?> {
  @override
  GroupTask? build() => null;

  Future<CreateGroupTaskResult> create({
    required String groupId,
    required String title,
    required String? notes,
    required String? assignedTo,
    required GroupTaskPriority priority,
    required DateTime? dueAt,
  }) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result = await ref.read(createGroupTaskProvider)(
      session: session,
      groupId: groupId,
      title: title,
      notes: notes,
      assignedTo: assignedTo,
      priority: priority,
      dueAt: dueAt,
    );
    state = switch (result) {
      CreateGroupTaskSuccess(:final task) => AsyncData(task),
      CreateGroupTaskFailure() => const AsyncData(null),
    };
    return result;
  }
}

final taskCompletionControllerProvider =
    AsyncNotifierProvider<TaskCompletionController, String?>(
        TaskCompletionController.new);

final class TaskCompletionController extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<CompleteGroupTaskResult> complete({
    required String groupId,
    required String taskId,
  }) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result = await ref.read(completeGroupTaskProvider)(
      session: session,
      groupId: groupId,
      taskId: taskId,
    );
    state = switch (result) {
      CompleteGroupTaskSuccess(:final taskId) => AsyncData(taskId),
      CompleteGroupTaskFailure() => const AsyncData(null),
    };
    return result;
  }
}

String _newTaskId() {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure();
  final suffix =
      List.generate(6, (_) => random.nextInt(36).toRadixString(36)).join();
  return 'task-$timestamp-$suffix';
}
