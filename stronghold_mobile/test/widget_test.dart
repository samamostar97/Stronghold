import 'package:flutter_test/flutter_test.dart';

import 'package:stronghold_mobile/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StrongholdApp());

    // Verify that the login screen shows key elements
    expect(find.text('STRONGHOLD'), findsOneWidget);
    expect(find.text('PRIJAVI SE'), findsOneWidget);
    expect(find.text('Registrujte se'), findsOneWidget);
  });
}
