import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'payment_screen.dart';
import 'consts.dart';

class TicketBookingScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;
  const TicketBookingScreen({super.key, required this.eventData});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  String? selectedCat;
  double ticketPrice = 0.0;
  List<String> selectedSeats = [];
  TextEditingController promoCodeController = TextEditingController();
  String promoCodeMessage = "";

  // Function to normalize category names to specific string keys
  String normalizeCategory(String category) {
    Map<String, String> categoryMap = {
      'General Admission': 'generalAdmission',
      'Senior Citizen': 'seniorCitizen',
      'VIP': 'vip',
      'Child': 'child',
    };

    return categoryMap[category] ?? category; // Default to input if not mapped
  }

  // Function to generate seat sections based on the seat limit
  List<String> generateSeatSections(int limit) {
    List<String> sections = [];
    if (limit <= 0) return sections; // Prevent empty seat list issues

    for (int i = 1; i <= limit; i++) {
      // Use the first letter of the category for the seat code prefix
      String seatCode = "${selectedCat?.substring(0, 1).toLowerCase()}-$i";
      sections.add(seatCode);
    }

    print("Generated Seat Sections: $sections"); // Debugging
    return sections;
  }

  // Function to check if the seat is reserved
  bool isReservedSeat(String seatCode) {
    return widget.eventData['ticketSetup']['bookedSeats']?.contains(seatCode) ??
        false;
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
              fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedCat,
                    hint: Text("Choose a Category".tr(),
                        style: TextStyle(color: Colors.white)),
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    dropdownColor: appBackgroundColor,
                    isExpanded: true,
                    items: widget
                        .eventData['ticketSetup']['categoryAvailability'].keys
                        .where((category) =>
                            widget.eventData['ticketSetup']
                                ['categoryAvailability'][category] ==
                            true)
                        .map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (newCategory) {
                      setState(() {
                        selectedCat = newCategory;
                        if (selectedCat != null) {
                          String normalizedCategory =
                              normalizeCategory(selectedCat!);
                          var categoryData = widget.eventData['ticketSetup']
                                  [normalizedCategory] ??
                              {};
                          ticketPrice = double.tryParse(
                                  categoryData['price']?.toString() ?? '0') ??
                              0.0;
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
                children: [
                  Text(
                    "Select Your Seats:".tr(),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: generateSeatSections(int.tryParse(widget
                                  .eventData['ticketSetup']
                                      [normalizeCategory(selectedCat!)]['limit']
                                  ?.toString() ??
                              '0')!)
                          .length,
                      itemBuilder: (context, index) {
                        String seatCode = generateSeatSections(int.tryParse(
                            widget
                                    .eventData['ticketSetup']
                                        [normalizeCategory(selectedCat!)]
                                        ['limit']
                                    ?.toString() ??
                                '0')!)[index];

                        Color seatColor = isReservedSeat(seatCode)
                            ? Colors.black
                            : selectedSeats.contains(seatCode)
                                ? buttonColor
                                : grey;

                        return GestureDetector(
                          onTap: () {
                            if (!isReservedSeat(seatCode)) {
                              setState(() {
                                if (selectedSeats.contains(seatCode)) {
                                  selectedSeats.remove(seatCode);
                                } else {
                                  selectedSeats.add(seatCode);
                                }
                              });
                            }
                          },
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              color: seatColor,
                              borderRadius: BorderRadius.circular(7.5),
                            ),
                            child: Center(
                              child: Text(
                                seatCode,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Color Legend
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("Selected Seat".tr(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white)),
                        const SizedBox(width: 5),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("Reserved Seat".tr(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white)),
                        const SizedBox(width: 5),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: grey,
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("Available Seat".tr(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              icon:
                                  const Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  if (promoCodeController.text ==
                                      widget.eventData['ticketSetup']['promo']
                                          ['code']) {
                                    double discount = double.tryParse(widget
                                                .eventData['ticketSetup']
                                                    ['promo']['discount']
                                                ?.toString() ??
                                            '0') ??
                                        0.0;
                                    promoCodeMessage =
                                        "Promo code applied!".tr();
                                    ticketPrice = ticketPrice -
                                        (ticketPrice * (discount / 100));
                                  } else {
                                    promoCodeMessage =
                                        "Invalid promo code.".tr();
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${"Total: RM".tr()}${(selectedSeats.length * ticketPrice).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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
                                        child: Text("OK".tr())),
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
                                    eventName: widget.eventData['eventName'],
                                    eventPoster: widget.eventData['posterUrl'],
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor),
                          child: Text("Proceed to Payment".tr(),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20)
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
