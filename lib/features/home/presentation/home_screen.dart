import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/re_mind_mark.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/home_tile.dart';

const _homeTiles = [
  HomeTile(
    title: 'Tonight Queue',
    body: 'Saved links for focused evening reading appear here.',
    kind: HomeTileKind.queue,
  ),
  HomeTile(
    title: 'Reading Streak',
    body: 'Complete your first read to begin a streak.',
    kind: HomeTileKind.streak,
  ),
  HomeTile(
    title: 'Family Tasks',
    body: 'Create a group before assigning shared tasks.',
    kind: HomeTileKind.group,
  ),
  HomeTile(
    title: 'Shared Alarms',
    body: 'Group alarms show delivery and dismissal status.',
    kind: HomeTileKind.alarm,
  ),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.save),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Save'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ReMindMark(size: 56),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppConstants.appName, style: theme.textTheme.headlineLarge),
                              Text(
                                AppConstants.tagline,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Settings',
                          onPressed: () => context.go(AppRoutes.settings),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _AuthStatusButton(authState: authState),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemCount: _homeTiles.length,
                itemBuilder: (context, index) {
                  return _HomeTileCard(tile: _homeTiles[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthStatusButton extends StatelessWidget {
  const _AuthStatusButton({required this.authState});

  final AsyncValue<AuthSession> authState;

  @override
  Widget build(BuildContext context) {
    final session = authState.value;
    final label = switch (session?.kind) {
      AuthSessionKind.signedIn => 'Syncing as ${session!.displayName}',
      AuthSessionKind.guest => 'Guest mode',
      AuthSessionKind.signedOut || null => 'Sign in to sync',
    };
    final icon = switch (session?.kind) {
      AuthSessionKind.signedIn => Icons.cloud_done_outlined,
      AuthSessionKind.guest => Icons.person_outline_rounded,
      AuthSessionKind.signedOut || null => Icons.login_rounded,
    };

    return FilledButton.icon(
      onPressed: () => context.go(AppRoutes.auth),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _HomeTileCard extends StatelessWidget {
  const _HomeTileCard({required this.tile});

  final HomeTile tile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          switch (tile.kind) {
            case HomeTileKind.queue:
              context.go(AppRoutes.queue('tonight'));
            case HomeTileKind.group:
              context.go(AppRoutes.groups);
            case HomeTileKind.alarm:
            case HomeTileKind.streak:
              context.go(AppRoutes.queue('recently-saved'));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(tile.kind), color: theme.colorScheme.primary),
              const SizedBox(height: 14),
              Text(tile.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  tile.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(HomeTileKind kind) {
    return switch (kind) {
      HomeTileKind.queue => Icons.bookmark_border_rounded,
      HomeTileKind.streak => Icons.local_fire_department_outlined,
      HomeTileKind.group => Icons.groups_2_outlined,
      HomeTileKind.alarm => Icons.notifications_active_outlined,
    };
  }
}
