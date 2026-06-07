import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/utils/validation.dart';
import '../../tasks/domain/complete_group_task.dart';
import '../../tasks/domain/create_group_task.dart';
import '../../tasks/domain/group_task.dart';
import '../../tasks/presentation/task_providers.dart';
import '../domain/create_group_invite.dart';
import '../domain/group_models.dart';
import 'group_providers.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider(groupId));
    final tasksState = ref.watch(groupTasksProvider(groupId));
    final group = groupState.value;
    return Scaffold(
      appBar: AppBar(title: Text(group?.name ?? 'Group')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskSheet(context, group),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Task'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          children: [
            Text('Shared tasks',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              group == null
                  ? 'Create tasks, assign owners, and keep completion status in sync with this group.'
                  : '${group.members.length} member${group.members.length == 1 ? '' : 's'} can coordinate tasks, alarms, and activity here.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => _showTaskSheet(context, group),
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Create task'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showInviteSheet(context),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Invite member'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            tasksState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const _TaskListError(),
              data: (tasks) => _TaskList(group: group, tasks: tasks),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _InviteMemberSheet(groupId: groupId),
    );
  }

  void _showTaskSheet(BuildContext context, Group? group) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateTaskSheet(groupId: groupId, group: group),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.group, required this.tasks});

  final Group? group;
  final List<GroupTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return const _EmptyTaskList();
    }
    final openTasks =
        tasks.where((task) => !task.isCompleted).toList(growable: false);
    final completedTasks =
        tasks.where((task) => task.isCompleted).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (openTasks.isNotEmpty) ...[
          Text('Open', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final task in openTasks) _TaskCard(group: group, task: task),
        ],
        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Completed', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final task in completedTasks)
            _TaskCard(group: group, task: task),
        ],
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.group, required this.task});

  final Group? group;
  final GroupTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final assignee =
        task.assignedTo == null ? null : group?.memberNamed(task.assignedTo!);
    final isCompleting = ref.watch(taskCompletionControllerProvider).isLoading;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(AppRoutes.taskDetail(task.groupId, task.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: task.isCompleted || isCompleting
                    ? null
                    : (_) => _complete(context, ref),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TaskChip(
                            label: task.priority.label,
                            icon: Icons.flag_outlined),
                        if (assignee != null)
                          _TaskChip(
                              label: assignee.displayName,
                              icon: Icons.person_outline_rounded),
                        if (task.dueAt != null)
                          _TaskChip(
                              label: _dateLabel(task.dueAt!),
                              icon: Icons.event_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
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

class _TaskChip extends StatelessWidget {
  const _TaskChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );
  }
}

class _EmptyTaskList extends StatelessWidget {
  const _EmptyTaskList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
            'No shared tasks yet. Create the first one when this group needs action.'),
      ),
    );
  }
}

class _TaskListError extends StatelessWidget {
  const _TaskListError();

  @override
  Widget build(BuildContext context) {
    return const Text(
        'Tasks could not be loaded. Check your connection and try again.');
  }
}

class _CreateTaskSheet extends ConsumerStatefulWidget {
  const _CreateTaskSheet({required this.groupId, required this.group});

  final String groupId;
  final Group? group;

  @override
  ConsumerState<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<_CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  GroupTaskPriority _priority = GroupTaskPriority.normal;
  String _assignedTo = '';
  DateTime? _dueAt;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(taskCreationControllerProvider).isLoading;
    final members = widget.group?.members ?? const <GroupMembership>[];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Create task',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.task_alt_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GroupTaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: [
                for (final priority in GroupTaskPriority.values)
                  DropdownMenuItem(
                      value: priority, child: Text(priority.label)),
              ],
              onChanged: (value) =>
                  setState(() => _priority = value ?? GroupTaskPriority.normal),
            ),
            if (members.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _assignedTo,
                decoration: const InputDecoration(
                  labelText: 'Assignee',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Unassigned')),
                  for (final member in members)
                    DropdownMenuItem(
                        value: member.userId, child: Text(member.displayName)),
                ],
                onChanged: (value) => setState(() => _assignedTo = value ?? ''),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDueDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(_dueAt == null
                  ? 'Add due date'
                  : 'Due ${_dateLabel(_dueAt!)}'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isLoading ? null : _submit,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_task_rounded),
              label: const Text('Create task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
      initialDate: _dueAt ?? DateTime(now.year, now.month, now.day),
    );
    if (selected != null) {
      setState(() => _dueAt = selected.toUtc());
    }
  }

  Future<void> _submit() async {
    final result =
        await ref.read(taskCreationControllerProvider.notifier).create(
              groupId: widget.groupId,
              title: _titleController.text,
              notes: _notesController.text,
              assignedTo: _assignedTo.isEmpty ? null : _assignedTo,
              priority: _priority,
              dueAt: _dueAt,
            );
    if (!mounted) {
      return;
    }

    switch (result) {
      case CreateGroupTaskSuccess():
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Task created.')));
      case CreateGroupTaskFailure(:final reason):
        final message =
            reason is Invalid ? reason.message : 'Could not create this task.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _InviteMemberSheet extends ConsumerStatefulWidget {
  const _InviteMemberSheet({required this.groupId});

  final String groupId;

  @override
  ConsumerState<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends ConsumerState<_InviteMemberSheet> {
  final _emailController = TextEditingController();
  String? _createdLink;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(groupInviteControllerProvider).isLoading;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite member',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'friend@example.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isLoading ? null : _submit,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link_rounded),
              label: const Text('Create invite'),
            ),
            if (_createdLink != null) ...[
              const SizedBox(height: 18),
              SelectableText(_createdLink!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final result =
        await ref.read(groupInviteControllerProvider.notifier).create(
              groupId: widget.groupId,
              recipientEmail: _emailController.text,
            );
    if (!mounted) {
      return;
    }

    switch (result) {
      case CreateGroupInviteSuccess(:final invite):
        setState(() => _createdLink = invite.deepLink);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite link created.')),
        );
      case CreateGroupInviteFailure(:final reason):
        final message = reason is Invalid
            ? reason.message
            : 'Could not create this invite.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
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
