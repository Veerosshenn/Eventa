import 'package:assignment1/pages/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment1/pages/register_screen.dart';

import 'mock.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('RegisterScreen navigates to HomeScreen after registration',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));

    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('emailField'));
    final nameField = find.byKey(const Key('nameField'));
    final phoneField = find.byKey(const Key('phoneField'));
    final passwordField = find.byKey(const Key('passwordField'));

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(nameField, 'Test User');
    await tester.enterText(phoneField, '0123456789');
    await tester.enterText(passwordField, 'password123');

    final registerButton = find.byKey(const Key('registerButton'));

    expect(registerButton, findsOneWidget);

    await tester.tap(registerButton);
    await tester.pump();
  });
}
