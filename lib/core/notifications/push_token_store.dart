final class PushTokenRecord {
  const PushTokenRecord({
    required this.uid,
    required this.tokenId,
    required this.token,
    required this.platform,
  });

  final String uid;
  final String tokenId;
  final String token;
  final String platform;
}

abstract interface class PushTokenStore {
  Future<void> registerToken(PushTokenRecord record);

  Future<void> unregisterToken(PushTokenRecord record);
}
