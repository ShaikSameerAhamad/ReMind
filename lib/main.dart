import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/notifications/flutter_local_notification_client.dart';
import 'core/notifications/notification_providers.dart';
import 'core/storage/app_storage.dart';
import 'features/alarms/data/alarm_repository_factory.dart';
import 'features/alarms/data/workmanager_alarm_fallback_scheduler.dart';
import 'features/alarms/presentation/alarm_providers.dart';
import 'features/auth/data/auth_repository_factory.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/groups/data/group_repository_factory.dart';
import 'features/groups/presentation/group_providers.dart';
import 'features/tasks/data/task_repository_factory.dart';
import 'features/tasks/presentation/task_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.ensureInitialized();
  final authRepository = await createDefaultAuthRepository();
  final groupRepository = await createDefaultGroupRepository();
  final taskRepository = await createDefaultTaskRepository();
  final alarmRepository = await createDefaultAlarmRepository();
  final alarmFallbackScheduler = WorkmanagerAlarmFallbackScheduler(
    workmanager: Workmanager(),
    now: DateTime.now,
  );
  await alarmFallbackScheduler.initialize();
  runApp(
    ProviderScope(
      overrides: [
        alarmRepositoryProvider.overrideWithValue(alarmRepository),
        localAlarmFallbackSchedulerProvider
            .overrideWithValue(alarmFallbackScheduler),
        localNotificationOpenClientProvider
            .overrideWithValue(FlutterLocalNotificationClient.instance),
        authRepositoryProvider.overrideWithValue(authRepository),
        groupRepositoryProvider.overrideWithValue(groupRepository),
        taskRepositoryProvider.overrideWithValue(taskRepository),
      ],
      child: const ReMindApp(),
    ),
  );
}
