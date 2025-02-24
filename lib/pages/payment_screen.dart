import 'consts.dart';
import 'main_screen.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String ticketType;
  final int ticketAmount;
  final String selectedSeats;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.ticketType,
    required this.ticketAmount,
    required this.selectedSeats,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String promoCode = "";
  bool isPromoValid = true;
  String selectedPaymentMethod = "Credit Card";
  bool paymentSuccessful = false;

  void handlePayment() {
    setState(() {
      paymentSuccessful = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Payment Success"),
          content:
              const Text("Your payment was successful. Check your profile."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Payment",
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
                  const Text(
                    "Ticket Summary",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ticket Type: ${widget.ticketType}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    "Ticket Number: ${widget.selectedSeats}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    "Amount of Ticket: ${(widget.ticketAmount)}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Total Amount: RM ${widget.totalAmount}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Select Payment Method:",
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
                      'debit_card.png',
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
                      'credit_card.png',
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
                      'tng.jpeg',
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Center(
                    child: Text(
                      "Pay Now",
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
