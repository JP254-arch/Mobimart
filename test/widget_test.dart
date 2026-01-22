import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobimart_app/app.dart'; // Make sure this matches your package structure

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Wait for widgets to settle
    await tester.pumpAndSettle();

    // Verify that MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the initial route (login screen) is present
    expect(find.text('Login'), findsOneWidget);

    // Optional: Verify that login email & password fields exist
    expect(find.byType(TextField), findsNWidgets(2));

    // Optional: Verify login button
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
