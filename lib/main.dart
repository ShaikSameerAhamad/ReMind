import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/app_storage.dart';
import 'features/auth/data/auth_repository_factory.dart';
import 'features/auth/presentation/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.ensureInitialized();
  final authRepository = await createDefaultAuthRepository();
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const ReMindApp(),
    ),
  );
}
