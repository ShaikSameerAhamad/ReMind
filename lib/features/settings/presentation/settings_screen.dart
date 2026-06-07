import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(_accountTitle(session)),
              subtitle: Text(_accountSubtitle(session)),
              trailing: TextButton(
                onPressed: () => context.go(AppRoutes.auth),
                child: Text(session?.kind == AuthSessionKind.signedIn ? 'Manage' : 'Sign in'),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('Notifications'),
              subtitle: Text('Control reminders, tasks, alarms, and digests.'),
            ),
            const ListTile(
              leading: Icon(Icons.text_fields_rounded),
              title: Text('Reader'),
              subtitle: Text('Choose reading theme, text size, and spacing.'),
            ),
            const ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Privacy'),
              subtitle: Text('Review account and data controls.'),
            ),
            if (session != null && session.kind != AuthSessionKind.signedOut)
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Log out'),
                subtitle: const Text('End this session on the device.'),
                onTap: authState.isLoading ? null : () => _signOut(context, ref),
              ),
          ],
        ),
      ),
    );
  }

  String _accountTitle(AuthSession? session) {
    return switch (session?.kind) {
      AuthSessionKind.signedIn => session!.displayName,
      AuthSessionKind.guest => 'Guest mode',
      AuthSessionKind.signedOut || null => 'Account',
    };
  }

  String _accountSubtitle(AuthSession? session) {
    return switch (session?.kind) {
      AuthSessionKind.signedIn => 'Cloud sync is enabled.',
      AuthSessionKind.guest => 'Personal saves stay on this device.',
      AuthSessionKind.signedOut || null => 'Sign in or continue as guest.',
    };
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) {
      return;
    }
    final error = ref.read(authControllerProvider).error;
    if (error != null) {
      final message = switch (error) {
        AuthException(:final message) => message,
        _ => 'Could not log out. Try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    context.go(AppRoutes.auth);
  }
}
