import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validation.dart';
import '../domain/create_group_invite.dart';
import 'group_providers.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Group activity',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Group $groupId is ready for members, tasks, shared alarms, and activity.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showInviteSheet(context),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Invite member'),
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
