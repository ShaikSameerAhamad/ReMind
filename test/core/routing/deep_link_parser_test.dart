import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/routing/app_routes.dart';
import 'package:remind/core/routing/deep_link_parser.dart';

void main() {
  test('parses queue deep links from FCM data', () {
    const parser = DeepLinkParser();

    final route = parser.routeFor({
      'deepLink': 'remind://queues/recently-saved',
    });

    expect(route, AppRoutes.queue('recently-saved'));
  });

  test('parses alarm deep links into received alarm route', () {
    const parser = DeepLinkParser();

    final route = parser.routeFor({
      'deepLink': 'remind://groups/family/alarms/alarm-1',
    });

    expect(route, AppRoutes.alarmReceived('family', 'alarm-1'));
  });

  test('parses typed task payloads', () {
    const parser = DeepLinkParser();

    final route = parser.routeFor({
      'type': 'task_assigned',
      'groupId': 'family',
      'taskId': 'task-1',
    });

    expect(route, AppRoutes.taskDetail('family', 'task-1'));
  });

  test('parses typed group payloads', () {
    const parser = DeepLinkParser();

    final route = parser.routeFor({
      'type': 'group_invite',
      'groupId': 'family',
    });

    expect(route, AppRoutes.groupDetail('family'));
  });

  test('parses group invite deep links and typed invite payloads', () {
    const parser = DeepLinkParser();

    expect(
      parser.routeFor({'deepLink': 'remind://groups/family/invites/INV123'}),
      AppRoutes.groupInvite('family', 'INV123'),
    );
    expect(
      parser.routeFor({
        'type': 'group_invite',
        'groupId': 'family',
        'inviteCode': 'INV123',
      }),
      AppRoutes.groupInvite('family', 'INV123'),
    );
  });

  test('rejects external links and unsafe route segments', () {
    const parser = DeepLinkParser();

    expect(parser.routeFor({'deepLink': 'https://example.com/phish'}), isNull);
    expect(
      parser.routeFor({
        'type': 'task_assigned',
        'groupId': 'family/bad',
        'taskId': 'task-1',
      }),
      isNull,
    );
  });
}
