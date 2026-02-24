import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stronghold_desktop/main.dart';

void main() {
  testWidgets('Desktop login screen displays correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    expect(find.text('TheStronghold'), findsOneWidget);
    expect(find.text('Dobrodosli nazad'), findsOneWidget);
    expect(find.text('KORISNICKO IME'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
