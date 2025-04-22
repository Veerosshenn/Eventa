import 'package:assignment1/pages/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BoughtTicketScreen extends StatefulWidget {
  const BoughtTicketScreen({super.key});

  @override
  _BoughtTicketScreen createState() => _BoughtTicketScreen();
}

class _BoughtTicketScreen extends State<BoughtTicketScreen> {
  // Fetches the list of booked tickets for the current user
  Future<List<Map<String, dynamic>>> getBookedTickets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User is not logged in.");
      return [];
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      List<dynamic> bookedTickets = userDoc['bookedTicket'] ?? [];
      List<Map<String, dynamic>> eventData = [];

      for (var ticket in bookedTickets) {
        final eventName = ticket['title'];
        debugPrint("Checking ticket for event: $eventName");

        if (eventName != null && eventName.isNotEmpty) {
          final eventDoc = await FirebaseFirestore.instance
              .collection('events')
              .where('eventName', isEqualTo: eventName)
              .get();

          if (eventDoc.docs.isNotEmpty) {
            debugPrint("Event found: ${eventDoc.docs.first.data()}");
            var event = eventDoc.docs.first.data();
            event['ticket'] = ticket; // Attach the ticket data to the event
            eventData.add(event);
          } else {
            debugPrint("No event found for title: $eventName");
          }
        } else {
          debugPrint("No eventName found in ticket");
        }
      }
      return eventData;
    } else {
      debugPrint("User document not found");
    }
    return [];
  }

  // Cancels a ticket booking and updates Firestore
  Future<void> cancelBooking(
      BuildContext context, String title, String selectedSeatsString) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        List<dynamic> bookedTickets = userDoc['bookedTicket'] ?? [];
        bookedTickets.removeWhere((ticket) => ticket['title'] == title);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'bookedTicket': bookedTickets});

        final eventDocSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .where('eventName', isEqualTo: title)
            .get();

        if (eventDocSnapshot.docs.isNotEmpty) {
          final eventDoc = eventDocSnapshot.docs.first;
          List<dynamic> bookedSeats =
              eventDoc['ticketSetup']['bookedSeats'] ?? [];

          // Split the selectedSeatsString by commas and remove extra spaces from each seat
          List<String> selectedSeats = selectedSeatsString
              .split(',')
              .map((seat) => seat.trim()) // Trim any spaces around each seat
              .toList();

          debugPrint("Selected seats to remove: $selectedSeats");

          // Remove each seat from the bookedSeats list
          bookedSeats.removeWhere((seat) => selectedSeats.contains(seat));

          debugPrint("Booked seats after removal: $bookedSeats");

          await FirebaseFirestore.instance
              .collection('events')
              .doc(eventDoc.id)
              .update({
            'ticketSetup.bookedSeats': bookedSeats,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Booking Cancelled")),
          );
        } else {
          debugPrint("Event not found for title: $title");
        }
      }
    } catch (e) {
      debugPrint("Error cancelling booking: $e");
    }
  }

  void showTicketPopup(BuildContext context, Map<String, dynamic> event,
      Map<String, dynamic> ticket) {
    bool canCancel = event['startTime'] != null && event['startTime'] != '';

    print("event ${ticket}");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("My Ticket".tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                height: 200,
                width: 200,
                child: QrImageView(
                  data: "${ticket['boughtTicketUID']}",
                )),
            SizedBox(height: 20),
            Text("${"Event:".tr()} ${event['eventName'] ?? 'Unknown Event'}",
                style: TextStyle(color: Colors.black)),
            Text(
                "${"Location:".tr()} ${event['location'] ?? 'Unknown Location'}",
                style: TextStyle(color: Colors.black)),
            Text("${"Date:".tr()} ${event['date'] ?? 'Unknown Date'}",
                style: TextStyle(color: Colors.black)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: canCancel
                  ? () async {
                      await cancelBooking(
                          context, event['eventName'], ticket['selectedSeats']);
                      Navigator.pop(context); // Close the popup
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canCancel ? Color(0xFFffb43b) : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                "Cancel Booking".tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("My Tickets".tr(), style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getBookedTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tickets found'.tr()));
          } else {
            final events = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final ticket = event['ticket']; // Get the ticket data

                  return GestureDetector(
                    onTap: () => showTicketPopup(context, event, ticket),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['eventName'] ?? 'Unknown Event',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  event['location'] ?? 'Unknown Location',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  event['date'] ?? 'Unknown Date',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  event['description'] ?? 'No Description',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: event['posterUrl'] != null
                                ? Image.network(
                                    event['posterUrl'],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 100,
                                    width: 100,
                                    color: Colors.grey,
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
