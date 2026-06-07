import 'package:remind/features/auth/domain/auth_repository.dart';
import 'package:remind/features/auth/domain/auth_session.dart';

final class RecordingAuthRepository implements AuthRepository {
  RecordingAuthRepository({
    AuthSession? initialSession,
    AuthSession? signInSession,
    AuthException? signInError,
  })  : _session = initialSession ?? const AuthSession.signedOut(),
        _signInSession = signInSession,
        _signInError = signInError;

  AuthSession _session;
  final AuthSession? _signInSession;
  final AuthException? _signInError;
  final actions = <String>[];

  @override
  Future<AuthSession> currentSession() async => _session;

  @override
  Future<AuthSession> continueAsGuest() async {
    actions.add('continueAsGuest');
    _session = AuthSession.guest(deviceId: 'device-xyz');
    return _session;
  }

  @override
  Future<AuthSession> signInWithGoogle() async {
    actions.add('signInWithGoogle');
    final error = _signInError;
    if (error != null) {
      throw error;
    }
    _session = _signInSession ??
        AuthSession.signedIn(
          profile: const AuthProfile(
            uid: 'uid-123',
            email: 'user@example.com',
            displayName: 'User',
            avatarUrl: null,
          ),
        );
    return _session;
  }

  @override
  Future<AuthSession> signOut() async {
    actions.add('signOut');
    _session = const AuthSession.signedOut();
    return _session;
  }
}
