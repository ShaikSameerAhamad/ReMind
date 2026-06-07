import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../features/auth/domain/auth_session.dart';
import 'push_messaging_client.dart';
import 'push_token_store.dart';

final class FcmTokenRegistrar {
  const FcmTokenRegistrar({
    required PushMessagingClient messagingClient,
    required PushTokenStore tokenStore,
    String platform = 'android',
  })  : _messagingClient = messagingClient,
        _tokenStore = tokenStore,
        _platform = platform;

  final PushMessagingClient _messagingClient;
  final PushTokenStore _tokenStore;
  final String _platform;

  Future<void> registerForSession(AuthSession session) async {
    if (!session.canUseCloud) {
      return;
    }

    await _messagingClient.requestPermission();
    final token = await _messagingClient.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await _tokenStore.registerToken(_recordFor(session: session, token: token));
  }

  Future<void> unregisterForSession(AuthSession session) async {
    if (!session.canUseCloud) {
      return;
    }

    final token = await _messagingClient.getToken();
    if (token != null && token.isNotEmpty) {
      await _tokenStore.unregisterToken(_recordFor(session: session, token: token));
    }
    await _messagingClient.deleteToken();
  }

  StreamSubscription<String> startTokenRefreshRegistration(AuthSession Function() currentSession) {
    return _messagingClient.tokenRefreshes.listen((token) async {
      final session = currentSession();
      if (!session.canUseCloud || token.isEmpty) {
        return;
      }
      await _tokenStore.registerToken(_recordFor(session: session, token: token));
    });
  }

  PushTokenRecord _recordFor({required AuthSession session, required String token}) {
    return PushTokenRecord(
      uid: session.ownerId!,
      tokenId: sha256.convert(utf8.encode(token)).toString(),
      token: token,
      platform: _platform,
    );
  }
}
