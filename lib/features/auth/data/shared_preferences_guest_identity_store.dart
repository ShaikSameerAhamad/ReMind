import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/guest_identity_store.dart';

final class SharedPreferencesGuestIdentityStore implements GuestIdentityStore {
  SharedPreferencesGuestIdentityStore({
    required SharedPreferences preferences,
    Random? random,
  })  : _preferences = preferences,
        _random = random ?? Random.secure();

  static const _deviceIdKey = 'auth.guest.device_id';
  static const _isGuestActiveKey = 'auth.guest.is_active';

  final SharedPreferences _preferences;
  final Random _random;

  @override
  Future<String> deviceId() async {
    final existing = _preferences.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final created = _newDeviceId();
    await _preferences.setString(_deviceIdKey, created);
    return created;
  }

  @override
  Future<bool> isGuestActive() async {
    return _preferences.getBool(_isGuestActiveKey) ?? false;
  }

  @override
  Future<void> setGuestActive(bool isActive) {
    return _preferences.setBool(_isGuestActiveKey, isActive);
  }

  String _newDeviceId() {
    return List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}
