import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
        totalAmount: 200,
        ticketType: 'VIP',
        ticketAmount: 250,
        selectedSeats: 'A2',
        eventName: 'Musically',
        eventPoster: 'assets/image.png',
      ),
    ));

    var payment = find.text("Payment");
    var summary = find.text("Ticket Summary");
    var card = find.text("Card Details");
    var pay = find.text("Pay Now");

    expect(payment, findsOneWidget);
    expect(summary, findsOneWidget);
    expect(card, findsOneWidget);
    expect(pay, findsOneWidget);
  });
}
