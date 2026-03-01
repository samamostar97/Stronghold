import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stronghold_mobile/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: StrongholdApp()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('STRONGHOLD'), findsOneWidget);
    expect(find.text('PRIJAVI SE'), findsOneWidget);
    expect(find.text('Registrujte se'), findsOneWidget);
  });
}
