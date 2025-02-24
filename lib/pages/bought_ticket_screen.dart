import 'package:bit301_assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import 'package:bit301_assignment1/models/event_model.dart';

class BoughtTicketScreen extends StatelessWidget {
  final List<Event> events = [
    Event(
      title: "Music Festival 2025",
      location: "Stadium A, KL",
      duration: 180,
      poster: "music_festival.jpeg",
      description:
          "Join us for an exciting music festival featuring top artists from around the world.",
      price: 20,
      time: "8:00 p.m.",
    ),
    Event(
      title: "Tech Conference",
      location: "Convention Center",
      duration: 300,
      poster: "tech_conference.jpeg",
      description:
          "Explore the latest tech innovations at this year’s tech conference.",
      price: 50,
      time: "9:00 a.m.",
    ),
  ];

  void showTicketPopup(BuildContext context, Event event) {
    bool canCancel = event.time != '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Your Ticket"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("qr_code.png", height: 150, width: 150),
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: events.map((event) {
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
                            event.title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            event.location,
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${event.duration} mins",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 5),
                          Text(
                            event.description,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        event.poster,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
