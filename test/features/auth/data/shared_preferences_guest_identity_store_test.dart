import 'package:flutter_test/flutter_test.dart';
import 'package:remind/features/auth/data/shared_preferences_guest_identity_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('guest identity store creates stable guest device id', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesGuestIdentityStore(preferences: preferences);

    final first = await store.deviceId();
    final second = await store.deviceId();

    expect(first, isNotEmpty);
    expect(second, first);
  });

  test('guest identity store tracks active guest mode without removing device id', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesGuestIdentityStore(preferences: preferences);
    final deviceId = await store.deviceId();

    await store.setGuestActive(true);
    expect(await store.isGuestActive(), isTrue);

    await store.setGuestActive(false);
    expect(await store.isGuestActive(), isFalse);
    expect(await store.deviceId(), deviceId);
  });
}
