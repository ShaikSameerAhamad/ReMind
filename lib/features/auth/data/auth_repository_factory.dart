import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/auth_repository.dart';
import 'firebase_auth_repository.dart';
import 'local_guest_auth_repository.dart';
import 'shared_preferences_guest_identity_store.dart';

Future<AuthRepository> createDefaultAuthRepository() async {
  final preferences = await SharedPreferences.getInstance();
  final guestIdentityStore = SharedPreferencesGuestIdentityStore(preferences: preferences);
  final firebase = await FirebaseBootstrap.ensureInitialized();

  if (!firebase.isConfigured) {
    return LocalGuestAuthRepository(guestIdentityStore: guestIdentityStore);
  }

  return FirebaseAuthRepository(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn.instance,
    guestIdentityStore: guestIdentityStore,
  );
}
