import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class ReMindApp extends ConsumerWidget {
  const ReMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'reMind',
      debugShowCheckedModeBanner: false,
      theme: ReMindTheme.light(),
      darkTheme: ReMindTheme.dark(),
      routerConfig: router,
    );
  }
}
