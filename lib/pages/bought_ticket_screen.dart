import 'package:assignment1/pages/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoughtTicketScreen extends StatelessWidget {
  // Fetch the user's booked tickets from Firestore
  Future<List<Map<String, dynamic>>> getBookedTickets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      List<dynamic> bookedTickets = userDoc['bookedTicket'] ?? [];
      return bookedTickets
          .map((ticket) => ticket as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  void showTicketPopup(BuildContext context, Map<String, dynamic> event) {
    bool canCancel = event['startTime'] != '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Your Ticket"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/qr_code.png", height: 150, width: 150),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: canCancel
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Booking Cancelled")),
                      );
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
                "Cancel Booking",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
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
        title: Text("My Tickets", style: TextStyle(color: Colors.white)),
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
            return Center(child: Text('No tickets found'));
          } else {
            final events = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return GestureDetector(
                    onTap: () => showTicketPopup(context, event),
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
                                  event['title'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  event['location'],
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  event['date'],
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  event['description'],
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              event['poster'],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
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
