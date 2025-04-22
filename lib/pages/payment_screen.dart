import 'package:assignment1/pages/consts.dart';
import 'package:assignment1/pages/main_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String ticketType;
  final int ticketAmount;
  final String selectedSeats;
  final String eventName;
  final String eventPoster;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.ticketType,
    required this.ticketAmount,
    required this.selectedSeats,
    required this.eventName,
    required this.eventPoster,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String promoCode = "";
  bool isPromoValid = true;
  bool paymentSuccessful = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CardFieldInputDetails? _cardFieldInputDetails;

  Future<String?> getClientSecret() async {
    try {
      double amount = widget.totalAmount.toDouble();
      final callable =
          FirebaseFunctions.instance.httpsCallable('createPaymentIntent');

      print("Debugging $amount");
      final result = await callable.call({
        'amount': amount,
      });

      final clientSecret = result.data['clientSecret'];
      print("Client Secret: $clientSecret");
      return clientSecret;
    } catch (e) {
      print('Error calling createPaymentIntent: $e');
      return null;
    }
  }

  Future<void> handlePayment() async {
    if (_cardFieldInputDetails == null || !_cardFieldInputDetails!.complete) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Incomplete Card Details".tr()),
          content:
              Text("Please fill in all card details before proceeding.".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK".tr()),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final billingDetails = BillingDetails(
        email: FirebaseAuth.instance.currentUser?.email,
      );

      // 1. Get the client secret
      final clientSecret = await getClientSecret();
      if (clientSecret == null) throw Exception("Client secret is null");

      // 2. Create the payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      // 3. Confirm the payment
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethod.id,
          ),
        ),
      );

      // 4. Mark payment as successful
      setState(() {
        paymentSuccessful = true;
      });

      // 5. Save booking and show success dialog
      await saveBookingDetails();

      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Payment Success".tr()),
            content:
                Text("Your payment was successful. Check your profile.".tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text("OK".tr()),
              ),
            ],
          ),
        );
      });
    } catch (e) {
      print("Payment failed: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Payment Failed".tr()),
          content:
              Text("An error occurred while processing your payment.".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK".tr()),
            ),
          ],
        ),
      );
    }
  }

  Future<void> saveBookingDetails() async {
    try {
      var uuid = Uuid();
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final eventDocRef = _firestore.collection('events').doc(widget.eventName);

      List<String> selectedSeatsList =
          widget.selectedSeats.split(',').map((seat) => seat.trim()).toList();

      List<String> bookedSeats =
          selectedSeatsList.map((seat) => "$seat").toList();

      await eventDocRef.update({
        'ticketSetup.bookedSeats': FieldValue.arrayUnion(bookedSeats),
      });

      await _firestore.collection('users').doc(userId).update({
        'bookedTicket': FieldValue.arrayUnion([
          {
            'title': widget.eventName,
            'poster': widget.eventPoster,
            'ticketAmount': widget.ticketAmount,
            'totalAmount': widget.totalAmount,
            'ticketType': widget.ticketType,
            'selectedSeats': widget.selectedSeats,
            'boughtTicketUID': uuid.v4(),
          }
        ]),
      });
    } catch (e) {
      print("Error saving booking details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Payment".tr(),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: appBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Ticket Summary".tr(),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${"Ticket Type: ".tr()}${widget.ticketType}",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      "${"Ticket Number: ".tr()}${widget.selectedSeats}",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      "${"Amount of Ticket: ".tr()}${widget.ticketAmount}",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${"Total Amount: RM ".tr()}${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Card Details".tr(),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              CardField(
                onCardChanged: (card) {
                  setState(() {
                    _cardFieldInputDetails = card;
                  });
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: MaterialButton(
                  onPressed: handlePayment,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  color: Colors.green,
                  height: 70,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Center(
                      child: Text(
                        "Pay Now".tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
