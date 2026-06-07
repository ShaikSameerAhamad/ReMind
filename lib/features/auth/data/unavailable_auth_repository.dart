import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

final class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  Future<AuthSession> currentSession() async => const AuthSession.signedOut();

  @override
  Future<AuthSession> continueAsGuest() {
    throw const AuthException('Auth services are still starting. Try again in a moment.');
  }

  @override
  Future<AuthSession> signInWithGoogle() {
    throw const AuthException('Auth services are still starting. Try again in a moment.');
  }

  @override
  Future<AuthSession> signOut() async => const AuthSession.signedOut();
}
