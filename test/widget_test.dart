// This is a basic Flutter widget test for PantryPal.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:pantrypal/main.dart';

void main() {
  testWidgets('PantryPal app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PantryPalApp());

    // Verify that the app loads with login screen
    expect(find.text('PantryPal'), findsOneWidget);
    expect(find.text('Your Smart Kitchen Assistant'), findsOneWidget);
  });
}
