import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validation.dart';
import '../../groups/domain/group_models.dart';
import '../../groups/presentation/group_providers.dart';
import '../domain/add_task_comment.dart';
import '../domain/complete_group_task.dart';
import '../domain/group_task.dart';
import 'task_providers.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    required this.groupId,
    required this.taskId,
    super.key,
  });

  final String groupId;
  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(
        groupTaskProvider((groupId: widget.groupId, taskId: widget.taskId)));
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final isCompleting = ref.watch(taskCompletionControllerProvider).isLoading;
    final isCommenting = ref.watch(taskCommentControllerProvider).isLoading;
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
            final updater = task.updatedBy == null
                ? null
                : group?.memberNamed(task.updatedBy!);
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(task.title,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                if (task.notes != null)
                  Text(task.notes!,
                      style: Theme.of(context).textTheme.bodyLarge),
                if (updater != null && updater.userId != task.createdBy) ...[
                  const SizedBox(height: 16),
                  _UpdatedByBanner(member: updater),
                ],
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
                      : () => _complete(task),
                  icon: isCompleting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(task.isCompleted ? 'Completed' : 'Mark complete'),
                ),
                const SizedBox(height: 32),
                Text('Comments', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (task.comments.isEmpty)
                  Text(
                    'No comments yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  )
                else
                  for (final comment in task.comments)
                    _CommentTile(comment: comment),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Add a comment',
                    prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (_) => _addComment(task),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: isCommenting ? null : () => _addComment(task),
                    icon: isCommenting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: const Text('Send'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _complete(GroupTask task) async {
    final result =
        await ref.read(taskCompletionControllerProvider.notifier).complete(
              groupId: task.groupId,
              taskId: task.id,
            );
    if (!mounted) {
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

  Future<void> _addComment(GroupTask task) async {
    final result = await ref.read(taskCommentControllerProvider.notifier).add(
          groupId: task.groupId,
          taskId: task.id,
          text: _commentController.text,
        );
    if (!mounted) {
      return;
    }
    switch (result) {
      case AddTaskCommentSuccess():
        _commentController.clear();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Comment added.')));
      case AddTaskCommentFailure(:final reason):
        final message =
            reason is Invalid ? reason.message : 'Could not add this comment.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _UpdatedByBanner extends StatelessWidget {
  const _UpdatedByBanner({required this.member});

  final GroupMembership member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.sync_problem_rounded,
                color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This task was edited by ${member.displayName}.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final TaskComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.authorName, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(comment.text),
            ],
          ),
        ),
      ),
    );
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
