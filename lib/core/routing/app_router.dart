import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alarms/presentation/alarm_received_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/groups/presentation/group_detail_screen.dart';
import '../../features/groups/presentation/group_invite_screen.dart';
import '../../features/groups/presentation/groups_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/queue/presentation/queue_screen.dart';
import '../../features/save/presentation/save_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.save,
        builder: (context, state) => const SaveScreen(),
      ),
      GoRoute(
        path: AppRoutes.groups,
        builder: (context, state) => const GroupsScreen(),
      ),
      GoRoute(
        path: AppRoutes.groupDetailPattern,
        builder: (context, state) => GroupDetailScreen(
          groupId: state.pathParameters['groupId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.groupInvitePattern,
        builder: (context, state) => GroupInviteScreen(
          groupId: state.pathParameters['groupId']!,
          inviteCode: state.pathParameters['inviteCode']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.taskDetailPattern,
        builder: (context, state) => TaskDetailScreen(
          groupId: state.pathParameters['groupId']!,
          taskId: state.pathParameters['taskId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.queuePattern,
        builder: (context, state) => QueueScreen(
          queueId: state.pathParameters['queueId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.alarmReceivedPattern,
        builder: (context, state) => AlarmReceivedScreen(
          groupId: state.pathParameters['groupId']!,
          alarmId: state.pathParameters['alarmId']!,
        ),
      ),
    ],
  );
});
