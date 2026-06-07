import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_providers.dart';
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
    await _run(() async {
      final session = await ref.read(authRepositoryProvider).signInWithGoogle();
      final registrar = await ref.read(fcmTokenRegistrarProvider.future);
      await registrar?.registerForSession(session);
      return session;
    });
  }

  Future<void> signOut() async {
    final currentSession = state.value;
    await _run(() async {
      final registrar = await ref.read(fcmTokenRegistrarProvider.future);
      if (currentSession != null) {
        await registrar?.unregisterForSession(currentSession);
      }
      return ref.read(authRepositoryProvider).signOut();
    });
  }

  Future<void> _run(Future<AuthSession> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}
