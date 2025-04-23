import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment1/pages/home_screen.dart';

import 'mock.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('HomeScreen Widget Testing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(),
    ));

    var event = find.text("What's available now");
    var search = find.text("Search");
    var des = find.text("Relax, book your tickets, and enjoy the events!");

    expect(event, findsOneWidget);
    expect(search, findsOneWidget);
    expect(des, findsOneWidget);
  });
}
