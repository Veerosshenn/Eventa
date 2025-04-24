import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment1/pages/payment_screen.dart';

import 'mock.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('HomeScreen Widget Testing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: PaymentScreen(
        totalAmount: 200.0,
        ticketType: 'VIP',
        ticketAmount: 1,
        selectedSeats: 'A2',
        eventName: 'Musically',
        eventPoster: 'assets/image.png',
      ),
    ));

    await tester.pumpAndSettle();

    final cardFieldFinder = find.byType(CardField);

    final payButtonFinder = find.widgetWithText(MaterialButton, "Pay Now");

    expect(cardFieldFinder, findsOneWidget);

    expect(payButtonFinder, findsOneWidget);

    await tester.tap(payButtonFinder);
    await tester.pump();
  });
}
