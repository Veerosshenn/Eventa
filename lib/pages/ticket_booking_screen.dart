import 'package:bit301_assignment1/models/event_model.dart';
import 'package:bit301_assignment1/models/seats_model.dart';
import 'package:bit301_assignment1/pages/consts.dart';
import 'package:bit301_assignment1/pages/payment_screen.dart';
import 'package:flutter/material.dart';

class TicketBookingScreen extends StatefulWidget {
  final Event event;
  const TicketBookingScreen({super.key, required this.event});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  String? selectedCat;
  double ticketPrice = 0.0;
  List<String> selectedSeats = [];
  TextEditingController promoCodeController = TextEditingController();
  String promoCodeMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "Select Seats",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Image.asset(
              'hall_layout.png',
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Category",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedCat,
                  hint: const Text(
                    "Choose a Category",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.black,
                  isExpanded: true,
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(
                        cat,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newCat) {
                    setState(() {
                      selectedCat = newCat;
                      if (selectedCat != null) {
                        ticketPrice = widget.event.price;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (selectedCat != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Select your seat:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: seatsByCategory[selectedCat]?.length ?? 0,
                    itemBuilder: (context, index) {
                      String seatNum = seatsByCategory[selectedCat]![index];
                      Color seatColor;
                      if (selectedSeats.contains(seatNum)) {
                        seatColor = buttonColor;
                      } else if (reversedSeats.contains(seatNum)) {
                        seatColor = Colors.grey;
                      } else {
                        seatColor = grey;
                      }
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedSeats.contains(seatNum)) {
                              selectedSeats.remove(seatNum);
                            } else if (!reversedSeats.contains(seatNum)) {
                              selectedSeats.add(seatNum);
                            }
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: seatColor,
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                          child: Center(
                            child: Text(
                              seatNum,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Available",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Selected",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Reserved",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter Promotional Code",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: promoCodeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          hintText: "Enter promo code",
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (promoCodeController.text == 'DISCOUNT10') {
                                  promoCodeMessage =
                                      "Promo code applied! 10% off.";
                                  ticketPrice *= 0.9;
                                } else {
                                  promoCodeMessage = "Invalid promo code.";
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      if (promoCodeMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            promoCodeMessage,
                            style: const TextStyle(color: Colors.yellow),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total: RM ${(selectedSeats.length * ticketPrice).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedSeats.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("No Seats Selected"),
                                content: const Text(
                                    "Please select seats before booking."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  ticketType: selectedCat ?? "",
                                  ticketAmount: selectedSeats.length,
                                  selectedSeats: selectedSeats.join(', '),
                                  totalAmount:
                                      selectedSeats.length * ticketPrice,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: const Text(
                            "Book Ticket",
                            style: TextStyle(
                              fontSize: 15,
                              height: 3,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
