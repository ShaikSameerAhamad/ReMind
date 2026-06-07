import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/notifications/fcm_token_registrar.dart';
import 'package:remind/core/notifications/push_messaging_client.dart';
import 'package:remind/core/notifications/push_token_store.dart';
import 'package:remind/features/auth/domain/auth_session.dart';

void main() {
  test('registerForSession skips signed out and guest sessions', () async {
    final client = _RecordingPushMessagingClient(token: 'token-1');
    final store = _RecordingPushTokenStore();
    final registrar = FcmTokenRegistrar(messagingClient: client, tokenStore: store);

    await registrar.registerForSession(const AuthSession.signedOut());
    await registrar.registerForSession(AuthSession.guest(deviceId: 'device-1'));

    expect(client.requestPermissionCalls, 0);
    expect(store.registered, isEmpty);
  });

  test('registerForSession requests permission and stores token by hashed id', () async {
    final client = _RecordingPushMessagingClient(token: 'fcm-token-secret');
    final store = _RecordingPushTokenStore();
    final registrar = FcmTokenRegistrar(messagingClient: client, tokenStore: store);

    await registrar.registerForSession(_signedInSession());

    expect(client.requestPermissionCalls, 1);
    expect(store.registered.single.uid, 'uid-1');
    expect(store.registered.single.token, 'fcm-token-secret');
    expect(store.registered.single.tokenId, hasLength(64));
    expect(store.registered.single.tokenId, isNot('fcm-token-secret'));
  });

  test('registerForSession does not store missing token', () async {
    final client = _RecordingPushMessagingClient(token: null);
    final store = _RecordingPushTokenStore();
    final registrar = FcmTokenRegistrar(messagingClient: client, tokenStore: store);

    await registrar.registerForSession(_signedInSession());

    expect(client.requestPermissionCalls, 1);
    expect(store.registered, isEmpty);
  });

  test('unregisterForSession removes current token and deletes local FCM token', () async {
    final client = _RecordingPushMessagingClient(token: 'fcm-token-secret');
    final store = _RecordingPushTokenStore();
    final registrar = FcmTokenRegistrar(messagingClient: client, tokenStore: store);

    await registrar.unregisterForSession(_signedInSession());

    expect(store.unregistered.single.uid, 'uid-1');
    expect(store.unregistered.single.token, 'fcm-token-secret');
    expect(client.deleteTokenCalls, 1);
  });

  test('startTokenRefreshRegistration stores refresh tokens for signed in session', () async {
    final controller = StreamController<String>();
    final client = _RecordingPushMessagingClient(
      token: 'initial-token',
      refreshes: controller.stream,
    );
    final store = _RecordingPushTokenStore();
    final registrar = FcmTokenRegistrar(messagingClient: client, tokenStore: store);

    final subscription = registrar.startTokenRefreshRegistration(() => _signedInSession());
    controller.add('refreshed-token');
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    await controller.close();

    expect(store.registered.single.token, 'refreshed-token');
    expect(store.registered.single.uid, 'uid-1');
  });
}

AuthSession _signedInSession() {
  return AuthSession.signedIn(
    profile: const AuthProfile(
      uid: 'uid-1',
      email: 'sameer@example.com',
      displayName: 'Sameer',
      avatarUrl: null,
    ),
  );
}

final class _RecordingPushMessagingClient implements PushMessagingClient {
  _RecordingPushMessagingClient({
    required this.token,
    Stream<String>? refreshes,
  }) : _refreshes = refreshes ?? const Stream.empty();

  final String? token;
  final Stream<String> _refreshes;
  var requestPermissionCalls = 0;
  var deleteTokenCalls = 0;

  @override
  Stream<String> get tokenRefreshes => _refreshes;

  @override
  Future<void> deleteToken() async {
    deleteTokenCalls += 1;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> requestPermission() async {
    requestPermissionCalls += 1;
  }
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
