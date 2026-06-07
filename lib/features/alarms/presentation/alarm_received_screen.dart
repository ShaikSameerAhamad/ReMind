import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validation.dart';
import '../domain/dismiss_shared_alarm.dart';
import '../domain/shared_alarm.dart';
import 'alarm_providers.dart';

class AlarmReceivedScreen extends ConsumerWidget {
  const AlarmReceivedScreen({
    required this.groupId,
    required this.alarmId,
    super.key,
  });

  final String groupId;
  final String alarmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmState =
        ref.watch(sharedAlarmProvider((groupId: groupId, alarmId: alarmId)));
    final isDismissing = ref.watch(alarmDismissalControllerProvider).isLoading;
    return Scaffold(
      backgroundColor: ReMindColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: alarmState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _CriticalMessage(
              title: 'Shared alarm',
              body:
                  'This alarm could not be loaded. Check your connection and try again.',
              action: _DismissButton(
                isLoading: false,
                label: 'Close',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            data: (alarm) {
              if (alarm == null) {
                return _CriticalMessage(
                  title: 'Shared alarm',
                  body: 'This alarm is no longer available.',
                  action: _DismissButton(
                    isLoading: false,
                    label: 'Close',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                );
              }
              return _CriticalMessage(
                title: alarm.title,
                body: alarm.message ?? 'Shared alarm due now.',
                metadata: _alarmMetadata(alarm),
                action: _DismissButton(
                  isLoading: isDismissing,
                  label: alarm.dismissals.isEmpty ? 'Dismiss' : 'Dismissed',
                  onPressed:
                      isDismissing ? null : () => _dismiss(context, ref, alarm),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _dismiss(
      BuildContext context, WidgetRef ref, SharedAlarm alarm) async {
    final result =
        await ref.read(alarmDismissalControllerProvider.notifier).dismiss(
              groupId: alarm.groupId,
              alarmId: alarm.id,
            );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case DismissSharedAlarmSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alarm dismissed.')),
        );
      case DismissSharedAlarmFailure(:final reason):
        final message = reason is Invalid
            ? reason.message
            : 'Could not dismiss this alarm.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _alarmMetadata(SharedAlarm alarm) {
    final local = alarm.scheduledAt.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} $hour:$minute';
  }
}

class _CriticalMessage extends StatelessWidget {
  const _CriticalMessage({
    required this.title,
    required this.body,
    required this.action,
    this.metadata,
  });

  final String title;
  final String body;
  final String? metadata;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .displayLarge
              ?.copyWith(color: ReMindColors.cloud),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ReMindColors.cloud.withValues(alpha: 0.78),
              ),
        ),
        if (metadata != null) ...[
          const SizedBox(height: 16),
          Text(
            metadata!,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: ReMindColors.mint),
          ),
        ],
        const SizedBox(height: 32),
        action,
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check_circle_outline_rounded),
      label: Text(label),
    );
  }
}
