import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../save/presentation/save_providers.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({required this.queueId, super.key});

  final String queueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(savedItemsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(queueId))),
      body: SafeArea(
        child: items.when(
          data: (savedItems) {
            if (savedItems.isEmpty) {
              return const _QueueEmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = savedItems[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark_border_rounded),
                    title: Text(item.title),
                    subtitle: Text(item.sourceDomain ?? item.url),
                    trailing: item.syncStatus.name == 'pending'
                        ? const Icon(Icons.sync_rounded, semanticLabel: 'Pending sync')
                        : const Icon(Icons.check_circle_outline_rounded, semanticLabel: 'Saved locally'),
                  ),
                );
              },
            );
          },
          error: (error, _) => _QueueErrorState(message: error.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  String _titleFor(String id) {
    return switch (id) {
      'tonight' => 'Tonight Queue',
      'weekend' => 'Weekend Queue',
      'forgotten' => 'Forgotten Queue',
      'recently-saved' => 'Recently Saved',
      _ => 'Queue',
    };
  }
}

class _QueueEmptyState extends StatelessWidget {
  const _QueueEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Your queue is ready for real saves', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Saved articles, videos, and learning links will appear here when they match this queue.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _QueueErrorState extends StatelessWidget {
  const _QueueErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Queue unavailable', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
