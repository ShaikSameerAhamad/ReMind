import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/utils/validation.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/accept_group_invite.dart';
import 'group_providers.dart';

class GroupInviteScreen extends ConsumerWidget {
  const GroupInviteScreen({
    required this.groupId,
    required this.inviteCode,
    super.key,
  });

  final String groupId;
  final String inviteCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.value;
    final isLoading =
        ref.watch(groupInviteAcceptanceControllerProvider).isLoading;
    final canAccept = session?.canUseCloud ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Group invite')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join this group',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                canAccept
                    ? 'Accept this invite to add the group to your shared workspace on every signed-in device.'
                    : 'Sign in with Google to accept this invite and sync the group across your devices.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (authState.isLoading && session == null)
                const Center(child: CircularProgressIndicator())
              else if (canAccept)
                FilledButton.icon(
                  onPressed:
                      isLoading ? null : () => _acceptInvite(context, ref),
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.group_add_outlined),
                  label: const Text('Accept invite'),
                )
              else
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.auth),
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text('Sign in to continue'),
                ),
              const SizedBox(height: 16),
              Text(
                'Invite code $inviteCode',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptInvite(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(groupInviteAcceptanceControllerProvider.notifier).accept(
              groupId: groupId,
              inviteCode: inviteCode,
            );
    if (!context.mounted) {
      return;
    }

    switch (result) {
      case AcceptGroupInviteSuccess(:final groupId):
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined group.')),
        );
        context.go(AppRoutes.groupDetail(groupId));
      case AcceptGroupInviteFailure(:final reason):
        final message = reason is Invalid
            ? reason.message
            : 'Could not accept this invite.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
