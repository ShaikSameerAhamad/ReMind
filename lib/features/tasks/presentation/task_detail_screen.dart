import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validation.dart';
import '../../groups/presentation/group_providers.dart';
import '../domain/complete_group_task.dart';
import '../domain/group_task.dart';
import 'task_providers.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({
    required this.groupId,
    required this.taskId,
    super.key,
  });

  final String groupId;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState =
        ref.watch(groupTaskProvider((groupId: groupId, taskId: taskId)));
    final group = ref.watch(groupProvider(groupId)).value;
    final isCompleting = ref.watch(taskCompletionControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Task')),
      body: SafeArea(
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
                'Task could not be loaded. Check your connection and try again.'),
          ),
          data: (task) {
            if (task == null) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Task not found.'),
              );
            }
            final assignee = task.assignedTo == null
                ? null
                : group?.memberNamed(task.assignedTo!);
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(task.title,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                if (task.notes != null)
                  Text(task.notes!,
                      style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                _DetailRow(
                    label: 'Status',
                    value: task.isCompleted ? 'Completed' : 'Open'),
                _DetailRow(label: 'Priority', value: task.priority.label),
                if (assignee != null)
                  _DetailRow(label: 'Assigned to', value: assignee.displayName),
                if (task.dueAt != null)
                  _DetailRow(label: 'Due', value: _dateLabel(task.dueAt!)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: task.isCompleted || isCompleting
                      ? null
                      : () => _complete(context, ref, task),
                  icon: isCompleting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(task.isCompleted ? 'Completed' : 'Mark complete'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _complete(
      BuildContext context, WidgetRef ref, GroupTask task) async {
    final result =
        await ref.read(taskCompletionControllerProvider.notifier).complete(
              groupId: task.groupId,
              taskId: task.id,
            );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case CompleteGroupTaskSuccess():
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Task completed.')));
      case CompleteGroupTaskFailure(:final reason):
        final message = reason is Invalid
            ? reason.message
            : 'Could not complete this task.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  final local = date.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}

extension on GroupTaskPriority {
  String get label {
    return switch (this) {
      GroupTaskPriority.low => 'Low',
      GroupTaskPriority.normal => 'Normal',
      GroupTaskPriority.high => 'High',
    };
  }
}
