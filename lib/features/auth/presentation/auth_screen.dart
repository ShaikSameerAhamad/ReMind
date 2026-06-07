import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.value;
    final isLoading = authState.isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 36),
            Icon(
              Icons.sync_rounded,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text('Keep your saves and groups in sync', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Sign in to sync saved links, family tasks, shared alarms, and reading progress across devices.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (session != null && session.kind != AuthSessionKind.signedOut) ...[
              const SizedBox(height: 20),
              _SessionBanner(session: session),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: isLoading ? null : () => _runAuthAction(context, ref, ref.read(authControllerProvider.notifier).signInWithGoogle),
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.account_circle_outlined),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoading ? null : () => _runAuthAction(context, ref, ref.read(authControllerProvider.notifier).continueAsGuest),
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Continue as Guest'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runAuthAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    await action();
    if (!context.mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    final error = authState.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFor(error))),
      );
      return;
    }

    final session = authState.value;
    if (session?.shouldPromptGuestMigration ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest saves are ready to migrate into this account.')),
      );
    }
    context.go(AppRoutes.home);
  }

  String _messageFor(Object error) {
    return switch (error) {
      AuthException(:final message) => message,
      _ => 'Could not complete sign-in. Try again.',
    };
  }
}

class _SessionBanner extends StatelessWidget {
  const _SessionBanner({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              session.canUseCloud ? Icons.verified_user_outlined : Icons.person_outline_rounded,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                session.canUseCloud ? 'Signed in as ${session.displayName}' : 'Guest mode is active on this device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
