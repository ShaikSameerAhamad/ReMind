import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/unavailable_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const UnavailableAuthRepository();
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthSession>(AuthController.new);

final authOwnerIdProvider = FutureProvider<String?>((ref) async {
  final session = await ref.watch(authControllerProvider.future);
  return session.ownerId;
});

final class AuthController extends AsyncNotifier<AuthSession> {
  @override
  Future<AuthSession> build() {
    return ref.watch(authRepositoryProvider).currentSession();
  }

  Future<void> continueAsGuest() async {
    await _run(ref.read(authRepositoryProvider).continueAsGuest);
  }

  Future<void> signInWithGoogle() async {
    await _run(ref.read(authRepositoryProvider).signInWithGoogle);
  }

  Future<void> signOut() async {
    await _run(ref.read(authRepositoryProvider).signOut);
  }

  Future<void> _run(Future<AuthSession> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}
