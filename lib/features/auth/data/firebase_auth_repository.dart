import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/guest_identity_store.dart';

final class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required GuestIdentityStore guestIdentityStore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _guestIdentityStore = guestIdentityStore;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final GuestIdentityStore _guestIdentityStore;
  var _hasInitializedGoogle = false;

  @override
  Future<AuthSession> currentSession() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return AuthSession.signedIn(profile: _profileFromFirebaseUser(firebaseUser));
    }

    if (await _guestIdentityStore.isGuestActive()) {
      return AuthSession.guest(deviceId: await _guestIdentityStore.deviceId());
    }

    return const AuthSession.signedOut();
  }

  @override
  Future<AuthSession> continueAsGuest() async {
    await _guestIdentityStore.setGuestActive(true);
    return AuthSession.guest(deviceId: await _guestIdentityStore.deviceId());
  }

  @override
  Future<AuthSession> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const AuthException('Google Sign-In is not available on this platform.');
    }

    final hadGuestSession = await _guestIdentityStore.isGuestActive();
    final googleAccount = await _googleSignIn.authenticate();
    final idToken = googleAccount.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('Google did not return an identity token.');
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(idToken: idToken);
    final credentials = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = credentials.user;
    if (firebaseUser == null) {
      throw const AuthException('Firebase did not return a signed-in user.');
    }

    final profile = _profileFromFirebaseUser(firebaseUser);
    await _upsertUserProfile(profile);
    await _guestIdentityStore.setGuestActive(false);

    return AuthSession.signedIn(
      profile: profile,
      shouldPromptGuestMigration: hadGuestSession,
    );
  }

  @override
  Future<AuthSession> signOut() async {
    await _ensureGoogleInitialized();
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await _guestIdentityStore.setGuestActive(false);
    return const AuthSession.signedOut();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_hasInitializedGoogle) {
      return;
    }
    await _googleSignIn.initialize();
    _hasInitializedGoogle = true;
  }

  AuthProfile _profileFromFirebaseUser(firebase_auth.User user) {
    return AuthProfile(
      uid: user.uid,
      email: user.email,
      displayName: _displayNameFor(user),
      avatarUrl: user.photoURL,
    );
  }

  String _displayNameFor(firebase_auth.User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'reMind user';
  }

  Future<void> _upsertUserProfile(AuthProfile profile) {
    return _firestore.collection('users').doc(profile.uid).set(
      {
        'uid': profile.uid,
        'profile': {
          'name': profile.displayName,
          'email': profile.email,
          'avatar': profile.avatarUrl,
        },
        'authProviders': FieldValue.arrayUnion(['google.com']),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
