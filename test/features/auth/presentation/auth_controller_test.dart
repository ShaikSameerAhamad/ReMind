import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/notifications/fcm_token_registrar.dart';
import 'package:remind/core/notifications/notification_providers.dart';
import 'package:remind/core/notifications/push_messaging_client.dart';
import 'package:remind/core/notifications/push_token_store.dart';
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

  test('auth controller registers FCM token after Google sign in', () async {
    final repository = _RecordingAuthRepository();
    final messaging = _RecordingPushMessagingClient(token: 'fcm-token');
    final tokenStore = _RecordingPushTokenStore();
    final registrar = FcmTokenRegistrar(messagingClient: messaging, tokenStore: tokenStore);
    final container = _containerFor(repository, registrar: registrar);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).signInWithGoogle();

    expect(tokenStore.registered.single.uid, 'uid-123');
    expect(tokenStore.registered.single.token, 'fcm-token');
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

  test('auth controller unregisters FCM token before sign out', () async {
    final repository = _RecordingAuthRepository(
      initialSession: AuthSession.signedIn(
        profile: const AuthProfile(
          uid: 'uid-789',
          email: 'signed@example.com',
          displayName: 'Signed',
          avatarUrl: null,
        ),
      ),
    );
    final messaging = _RecordingPushMessagingClient(token: 'fcm-token');
    final tokenStore = _RecordingPushTokenStore();
    final registrar = FcmTokenRegistrar(messagingClient: messaging, tokenStore: tokenStore);
    final container = _containerFor(repository, registrar: registrar);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).signOut();

    expect(tokenStore.unregistered.single.uid, 'uid-789');
    expect(tokenStore.unregistered.single.token, 'fcm-token');
    expect(messaging.deleteTokenCalls, 1);
  });
}

ProviderContainer _containerFor(AuthRepository repository, {FcmTokenRegistrar? registrar}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      fcmTokenRegistrarProvider.overrideWith((ref) async => registrar),
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

final class _RecordingPushMessagingClient implements PushMessagingClient {
  _RecordingPushMessagingClient({required this.token});

  final String? token;
  var deleteTokenCalls = 0;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<void> deleteToken() async {
    deleteTokenCalls += 1;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> requestPermission() async {}
}

final class _RecordingPushTokenStore implements PushTokenStore {
  final registered = <PushTokenRecord>[];
  final unregistered = <PushTokenRecord>[];

  @override
  Future<void> registerToken(PushTokenRecord record) async {
    registered.add(record);
  }

  @override
  Future<void> unregisterToken(PushTokenRecord record) async {
    unregistered.add(record);
  }
}
