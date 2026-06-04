import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AlarmReceivedScreen extends StatelessWidget {
  const AlarmReceivedScreen({
    required this.groupId,
    required this.alarmId,
    super.key,
  });

  final String groupId;
  final String alarmId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReMindColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Shared alarm',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: ReMindColors.cloud),
              ),
              const SizedBox(height: 12),
              Text(
                'Open reMind to review the group alarm, delivery state, and dismissal status.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ReMindColors.cloud.withValues(alpha: 0.78)),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
