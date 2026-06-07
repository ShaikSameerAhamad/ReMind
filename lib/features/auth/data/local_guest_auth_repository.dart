import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/guest_identity_store.dart';

final class LocalGuestAuthRepository implements AuthRepository {
  const LocalGuestAuthRepository({required GuestIdentityStore guestIdentityStore})
      : _guestIdentityStore = guestIdentityStore;

  final GuestIdentityStore _guestIdentityStore;

  @override
  Future<AuthSession> currentSession() async {
    if (!await _guestIdentityStore.isGuestActive()) {
      return const AuthSession.signedOut();
    }
    return AuthSession.guest(deviceId: await _guestIdentityStore.deviceId());
  }

  @override
  Future<AuthSession> continueAsGuest() async {
    await _guestIdentityStore.setGuestActive(true);
    return AuthSession.guest(deviceId: await _guestIdentityStore.deviceId());
  }

  @override
  Future<AuthSession> signInWithGoogle() {
    throw const AuthException(
      'Firebase is not configured yet. Add google-services.json, then sign in with Google.',
    );
  }

  @override
  Future<AuthSession> signOut() async {
    await _guestIdentityStore.setGuestActive(false);
    return const AuthSession.signedOut();
  }
}
