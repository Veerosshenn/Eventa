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

  testWidgets('RegisterScreen Widget Testing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));

    await tester.pumpAndSettle();

    var email = find.byKey(Key('emailField'));
    var name = find.byKey(Key('nameField'));
    var phone = find.byKey(Key('phoneField'));
    var password = find.byKey(Key('passwordField'));

    expect(email, findsOneWidget);
    expect(name, findsOneWidget);
    expect(phone, findsOneWidget);
    expect(password, findsOneWidget);

    var register = find.byType(ElevatedButton);
    expect(register, findsOneWidget);

    var login = find.text("Already have an account? Login");
    expect(login, findsOneWidget);
  });
}
