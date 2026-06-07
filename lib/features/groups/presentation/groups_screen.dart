import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/utils/validation.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/create_group.dart';
import 'group_providers.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.value;
    final canCreateGroup = session?.kind == AuthSessionKind.signedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Coordinate together', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Create a family or team group to assign tasks, set shared alarms, and keep activity visible.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            if (canCreateGroup) ...[
              FilledButton.icon(
                onPressed: () => _showCreateGroupSheet(context),
                icon: const Icon(Icons.group_add_outlined),
                label: const Text('Create group'),
              ),
            ] else ...[
              _UpgradePanel(onSignIn: () => context.go(AppRoutes.auth)),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CreateGroupSheet(),
    );
  }
}

class _UpgradePanel extends StatelessWidget {
  const _UpgradePanel({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign in to create groups', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Shared tasks and alarms need a secure account so every member sees the same group.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSignIn,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(groupCreationControllerProvider).isLoading;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create group', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  hintText: 'Family Chores',
                  prefixIcon: Icon(Icons.groups_2_outlined),
                ),
                validator: (value) {
                  final result = ReMindValidators.groupName(value ?? '');
                  return switch (result) {
                    Valid() => null,
                    Invalid(:final message) => message,
                  };
                },
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
                    : const Icon(Icons.check_rounded),
                label: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await ref
        .read(groupCreationControllerProvider.notifier)
        .create(name: _nameController.text);
    if (!mounted) {
      return;
    }

    switch (result) {
      case CreateGroupSuccess(:final group):
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${group.name} created.')),
        );
        context.go(AppRoutes.groupDetail(group.id));
      case CreateGroupFailure(:final reason):
        final message = reason is Invalid ? reason.message : 'Could not create this group.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
