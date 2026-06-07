import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/auth/domain/auth_repository.dart';
import 'package:remind/features/auth/domain/auth_session.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';

void main() {
  test('auth controller starts with repository session', () async {
    final repository = _RecordingAuthRepository(
      initialSession: AuthSession.guest(deviceId: 'device-abc'),
    );
    final container = _containerFor(repository);
    addTearDown(container.dispose);

    final session = await container.read(authControllerProvider.future);

    expect(session.ownerId, 'guest:device-abc');
    expect(session.canUseCloud, isFalse);
  });

  test('auth controller continues as guest', () async {
    final repository = _RecordingAuthRepository();
    final container = _containerFor(repository);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).continueAsGuest();

    final session = container.read(authControllerProvider).requireValue;
    expect(session.kind, AuthSessionKind.guest);
    expect(session.ownerId, 'guest:device-xyz');
    expect(repository.actions, ['continueAsGuest']);
  });

  test('auth controller signs in with Google and preserves migration signal', () async {
    final repository = _RecordingAuthRepository(
      signInSession: AuthSession.signedIn(
        profile: const AuthProfile(
          uid: 'uid-456',
          email: 'sameer@example.com',
          displayName: 'Sameer',
          avatarUrl: null,
        ),
        shouldPromptGuestMigration: true,
      ),
    );
    final container = _containerFor(repository);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).signInWithGoogle();

    final session = container.read(authControllerProvider).requireValue;
    expect(session.ownerId, 'uid-456');
    expect(session.canUseCloud, isTrue);
    expect(session.shouldPromptGuestMigration, isTrue);
    expect(repository.actions, ['signInWithGoogle']);
  });

  test('auth controller signs out', () async {
    final repository = _RecordingAuthRepository(
      initialSession: AuthSession.guest(deviceId: 'device-abc'),
    );
    final container = _containerFor(repository);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).signOut();

    final session = container.read(authControllerProvider).requireValue;
    expect(session.kind, AuthSessionKind.signedOut);
    expect(repository.actions, ['signOut']);
  });
}

ProviderContainer _containerFor(AuthRepository repository) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

final class _RecordingAuthRepository implements AuthRepository {
  _RecordingAuthRepository({
    AuthSession? initialSession,
    AuthSession? signInSession,
  })  : _session = initialSession ?? const AuthSession.signedOut(),
        _signInSession = signInSession;

  AuthSession _session;
  final AuthSession? _signInSession;
  final actions = <String>[];

  @override
  Future<AuthSession> currentSession() async => _session;

  @override
  Future<AuthSession> continueAsGuest() async {
    actions.add('continueAsGuest');
    _session = AuthSession.guest(deviceId: 'device-xyz');
    return _session;
  }

  @override
  Future<AuthSession> signInWithGoogle() async {
    actions.add('signInWithGoogle');
    _session = _signInSession ??
        AuthSession.signedIn(
          profile: const AuthProfile(
            uid: 'uid-123',
            email: 'user@example.com',
            displayName: 'User',
            avatarUrl: null,
          ),
        );
    return _session;
  }

  @override
  Future<AuthSession> signOut() async {
    actions.add('signOut');
    _session = const AuthSession.signedOut();
    return _session;
  }
}
