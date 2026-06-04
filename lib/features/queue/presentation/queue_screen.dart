import 'package:flutter/material.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({required this.queueId, super.key});

  final String queueId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(queueId))),
      body: SafeArea(
        child: Padding(
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
