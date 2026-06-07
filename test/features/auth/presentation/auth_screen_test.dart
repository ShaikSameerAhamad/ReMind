import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/app.dart';
import 'package:remind/features/auth/domain/auth_repository.dart';
import 'package:remind/features/auth/presentation/auth_controller.dart';

import '../../../support/recording_auth_repository.dart';

void main() {
  testWidgets('auth screen continues as guest and returns home', (tester) async {
    final repository = RecordingAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const ReMindApp(),
      ),
    );

    await tester.tap(find.text('Sign in to sync'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    expect(find.text('Guest mode'), findsOneWidget);
    expect(repository.actions, ['continueAsGuest']);
  });

  testWidgets('auth screen shows Google Sign-In errors', (tester) async {
    final repository = RecordingAuthRepository(
      signInError: const AuthException('Google Sign-In needs Firebase setup.'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const ReMindApp(),
      ),
    );

    await tester.tap(find.text('Sign in to sync'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Google Sign-In needs Firebase setup.'), findsOneWidget);
    expect(repository.actions, ['signInWithGoogle']);
  });
}
