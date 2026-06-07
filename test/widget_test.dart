import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind/app.dart';

void main() {
  testWidgets('renders reMind home shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReMindApp()));

    expect(find.text('reMind'), findsOneWidget);
    expect(find.text('Save smarter. Sync better'), findsOneWidget);
    expect(find.text('Tonight Queue'), findsOneWidget);
  });

  testWidgets('save action opens save screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReMindApp()));

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Save your first link'), findsOneWidget);
  });
}
