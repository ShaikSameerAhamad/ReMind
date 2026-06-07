import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/groups/domain/group_models.dart';

void main() {
  test('group exposes assignee choices from active members', () {
    final group = Group(
      id: 'family',
      name: 'Family',
      createdBy: 'uid-1',
      createdAt: DateTime.utc(2026, 6, 7),
      updatedAt: DateTime.utc(2026, 6, 7),
      lastActivityAt: DateTime.utc(2026, 6, 7),
      members: [
        GroupMembership(
          userId: 'uid-1',
          displayName: 'Sameer',
          role: GroupRole.admin,
          joinedAt: DateTime.utc(2026, 6, 7),
        ),
        GroupMembership(
          userId: 'uid-2',
          displayName: 'Aisha',
          role: GroupRole.member,
          joinedAt: DateTime.utc(2026, 6, 7),
        ),
      ],
    );

    expect(group.memberNamed('uid-2')?.displayName, 'Aisha');
    expect(group.memberNamed('missing'), isNull);
  });
}
