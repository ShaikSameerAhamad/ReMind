import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/app_storage.dart';
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
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        groupRepositoryProvider.overrideWithValue(groupRepository),
        taskRepositoryProvider.overrideWithValue(taskRepository),
      ],
      child: const ReMindApp(),
    ),
  );
}
