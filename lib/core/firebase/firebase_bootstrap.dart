import 'package:firebase_core/firebase_core.dart';

final class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({
    required this.isConfigured,
    required this.errorMessage,
  });

  final bool isConfigured;
  final String? errorMessage;
}

abstract final class FirebaseBootstrap {
  static Future<FirebaseBootstrapResult> ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return const FirebaseBootstrapResult(isConfigured: true, errorMessage: null);
    }

    try {
      await Firebase.initializeApp();
      return const FirebaseBootstrapResult(isConfigured: true, errorMessage: null);
    } catch (error) {
      return FirebaseBootstrapResult(isConfigured: false, errorMessage: error.toString());
    }
  }
}
