import 'package:assignment1/pages/consts.dart';
import 'package:assignment1/pages/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String ticketType;
  final int ticketAmount;
  final String selectedSeats;
  final String eventTitle; // Assuming you have the event title
  final String eventPoster; // Assuming you have the event poster URL

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.ticketType,
    required this.ticketAmount,
    required this.selectedSeats,
    required this.eventTitle, // Pass the event title
    required this.eventPoster, // Pass the event poster URL
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String promoCode = "";
  bool isPromoValid = true;
  String selectedPaymentMethod = "Credit Card";
  bool paymentSuccessful = false;

  // Reference to Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void handlePayment() {
    setState(() {
      paymentSuccessful = true;
    });

    // Save booking details to Firestore
    saveBookingDetails();

    Future.delayed(const Duration(seconds: 1), () {
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
                  MaterialPageRoute(builder: (_) => MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("OK".tr()),
            ),
          ],
        ),
      );
    });
  }

  Future<void> saveBookingDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('users').doc(userId).update({
        'bookedTicket': FieldValue.arrayUnion([
          {
            'title': widget.eventTitle,
            'poster': widget.eventPoster,
            'ticketAmount': widget.ticketAmount,
            'totalAmount': widget.totalAmount,
            'ticketType': widget.ticketType,
            'selectedSeats': widget.selectedSeats,
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
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Payment".tr(),
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${"Ticket Type: ".tr()}${widget.ticketType}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    "${"Ticket Number: ".tr()}${widget.selectedSeats}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    "${"Amount of Ticket: ".tr()}${(widget.ticketAmount)}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${"Total Amount: RM ".tr()}${widget.totalAmount}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Select Payment Method:".tr(),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/images/debit_card.png',
                      width: 200,
                      height: 80,
                    ),
                    Radio(
                      value: "Debit Card",
                      groupValue: selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    const Text(
                      "Debit Card",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/credit_card.png',
                      width: 200,
                      height: 80,
                    ),
                    Radio(
                      value: "Credit Card",
                      groupValue: selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    const Text(
                      "Credit Card",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/tng.jpeg',
                      width: 200,
                      height: 80,
                    ),
                    Radio(
                      value: "E-Wallet",
                      groupValue: selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    const Text(
                      "E-Wallet",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: MaterialButton(
                onPressed: () {
                  if (promoCode.isNotEmpty && !isPromoValid) {
                    setState(() {
                      isPromoValid = false;
                    });
                    return;
                  }
                  handlePayment();
                },
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
    );
  }
}
