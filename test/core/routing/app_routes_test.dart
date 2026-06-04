import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/routing/app_routes.dart';

void main() {
  test('task detail route requires group and task ids', () {
    expect(AppRoutes.taskDetail('family', 'task-1'), '/groups/family/tasks/task-1');
  });

  test('alarm received route requires group and alarm ids', () {
    expect(
      AppRoutes.alarmReceived('family', 'alarm-1'),
      '/groups/family/alarms/alarm-1/received',
    );
  });

  test('route segment rejects slashes', () {
    expect(() => AppRoutes.queue('bad/id'), throwsArgumentError);
  });
}
