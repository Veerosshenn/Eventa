import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'payment_screen.dart';
import 'consts.dart';

class TicketBookingScreen extends StatefulWidget {
  final Map<String, dynamic>
      eventData; // Updated to use a Map for event details
  const TicketBookingScreen({super.key, required this.eventData});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  String? selectedCat;
  double ticketPrice = 0.0;
  List<String> selectedSeats = [];
  List<String> reversedSeats = [];
  TextEditingController promoCodeController = TextEditingController();
  String promoCodeMessage = "";

  List<String> generateSeatOptions() {
    List<String> seatOptions = [];
    for (var category in widget.eventData['seatsByCategory'].keys) {
      List<String> seats = widget.eventData['seatsByCategory'][category] ?? [];
      seatOptions.addAll(seats);
    }
    return seatOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "Select Seats".tr(),
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Image.asset(
              'assets/images/hall_layout.png',
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
                Text(
                  "Select Category".tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedCat,
                  hint: Text(
                    "Choose a Seat".tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.black,
                  isExpanded: true,
                  items: generateSeatOptions().map((seat) {
                    return DropdownMenuItem<String>(
                      value: seat,
                      child: Text(
                        seat,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newSeat) {
                    setState(() {
                      selectedCat = newSeat;
                      if (selectedCat != null) {
                        if (widget.eventData['categoryAvailability']['VIP']!
                            .contains(newSeat)) {
                          ticketPrice =
                              widget.eventData['VIP']['price'][newSeat] ?? 0.0;
                        } else if (widget.eventData['categoryAvailability']
                                ['General Admission']!
                            .contains(newSeat)) {
                          ticketPrice = widget.eventData['General Asmission']
                                  ['price'][newSeat] ??
                              0.0;
                        } else if (widget.eventData['categoryAvailability']
                                ['Senior Citizen']!
                            .contains(newSeat)) {
                          ticketPrice = widget.eventData['Senior Citizen']
                                  ['price'][newSeat] ??
                              0.0;
                        } else if (widget.eventData['categoryAvailability']
                                ['Child']!
                            .contains(newSeat)) {
                          ticketPrice = widget.eventData['Child']['price']
                                  [newSeat] ??
                              0.0;
                        }
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
                Text(
                  "Select your seat:".tr(),
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
                    itemCount: widget
                            .eventData['categoryAvailability'][selectedCat]
                                ['limit']
                            ?.length ??
                        0,
                    itemBuilder: (context, index) {
                      String seatNum =
                          widget.eventData['bookedSeats'][selectedCat]![index];
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
                // Promo code handling
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Promotional Code".tr(),
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
                          hintText: "Enter promo code".tr(),
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (promoCodeController.text ==
                                    widget.eventData['promo']['code']) {
                                  promoCodeMessage = "Promo code applied!".tr();
                                  ticketPrice = ticketPrice /
                                      widget.eventData['discount'].double;
                                } else {
                                  promoCodeMessage = "Invalid promo code.".tr();
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
                      "${"Total: RM".tr()}${(selectedSeats.length * ticketPrice).toStringAsFixed(2)}",
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
                                title: Text("No Seats Selected".tr()),
                                content: Text(
                                    "Please select seats to proceed.".tr()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("OK".tr()),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  totalAmount:
                                      selectedSeats.length * ticketPrice,
                                  ticketType: selectedCat.toString(),
                                  ticketAmount: selectedSeats.length,
                                  selectedSeats: selectedSeats.join(', '),
                                  eventTitle: widget.eventData['title'],
                                  eventPoster: widget.eventData['posterUrl'],
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        child: Text(
                          "Proceed".tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
