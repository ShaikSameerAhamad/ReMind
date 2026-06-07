import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/auth/domain/auth_session.dart';

void main() {
  test('guest session is local-only and uses guest owner id', () {
    final session = AuthSession.guest(deviceId: 'device-123');

    expect(session.kind, AuthSessionKind.guest);
    expect(session.ownerId, 'guest:device-123');
    expect(session.canUseCloud, isFalse);
    expect(session.displayName, 'Guest');
  });

  test('signed in session can use cloud features and exposes profile identity', () {
    const profile = AuthProfile(
      uid: 'uid-123',
      email: 'sameer@example.com',
      displayName: 'Sameer',
      avatarUrl: 'https://example.com/avatar.png',
    );

    final session = AuthSession.signedIn(profile: profile, shouldPromptGuestMigration: true);

    expect(session.kind, AuthSessionKind.signedIn);
    expect(session.ownerId, 'uid-123');
    expect(session.canUseCloud, isTrue);
    expect(session.displayName, 'Sameer');
    expect(session.shouldPromptGuestMigration, isTrue);
  });
}
