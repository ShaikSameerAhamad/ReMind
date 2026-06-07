import 'auth_session.dart';

final class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  Future<AuthSession> currentSession();

  Future<AuthSession> continueAsGuest();

  Future<AuthSession> signInWithGoogle();

  Future<AuthSession> signOut();
}
