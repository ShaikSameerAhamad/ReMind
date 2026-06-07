abstract interface class PushMessagingClient {
  Stream<String> get tokenRefreshes;

  Future<void> requestPermission();

  Future<String?> getToken();

  Future<void> deleteToken();
}
