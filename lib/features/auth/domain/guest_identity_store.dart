abstract interface class GuestIdentityStore {
  Future<String> deviceId();

  Future<bool> isGuestActive();

  Future<void> setGuestActive(bool isActive);
}
