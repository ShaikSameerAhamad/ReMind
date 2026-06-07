import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/notifications/notification_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class ReMindApp extends ConsumerStatefulWidget {
  const ReMindApp({super.key});

  @override
  ConsumerState<ReMindApp> createState() => _ReMindAppState();
}

class _ReMindAppState extends ConsumerState<ReMindApp> {
  GoRouter? _activeRouter;
  StreamSubscription? _notificationSubscription;

  @override
  void dispose() {
    unawaited(_notificationSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    if (!identical(_activeRouter, router)) {
      _activeRouter = router;
      unawaited(_startNotificationRouting(router));
    }
    return MaterialApp.router(
      title: 'reMind',
      debugShowCheckedModeBanner: false,
      theme: ReMindTheme.light(),
      darkTheme: ReMindTheme.dark(),
      routerConfig: router,
    );
  }

  Future<void> _startNotificationRouting(GoRouter router) async {
    await _notificationSubscription?.cancel();
    final notificationRouter = await ref.read(notificationRouterProvider(router.go).future);
    if (!mounted || !identical(_activeRouter, router) || notificationRouter == null) {
      return;
    }
    _notificationSubscription = await notificationRouter.start();
  }
}
