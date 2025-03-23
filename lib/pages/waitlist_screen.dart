import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'consts.dart';
import 'main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Auth import

class WaitlistScreen extends StatefulWidget {
  @override
  _WaitlistScreenState createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  String? selectedEvent;
  bool isWaitlisted = false;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void fetchEvents() async {
    FirebaseFirestore.instance.collection('events').get().then((snapshot) {
      setState(() {
        events = snapshot.docs
            .map((doc) => doc.data())
            .where((event) => (event['bookedSeats'] as List).length == 300)
            .toList();
      });
    });
  }

  void joinWaitlist() async {
    if (selectedEvent != null) {
      setState(() {
        isWaitlisted = true;
      });

      // Get the selected event details
      var selectedEventDetails =
          events.firstWhere((event) => event['title'] == selectedEvent);

      // Get the current user's UID from FirebaseAuth
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Add the selected event to the user's waiting list array
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'waitingList': FieldValue.arrayUnion([
          {
            'title': selectedEventDetails['title'],
            'posterUrl': selectedEventDetails['posterUrl'],
          },
        ])
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Waitlist Confirmation".tr()),
          content: Text(
              "${"You have been added to the waitlist for ".tr()}$selectedEvent."),
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
    }
  }

  void leaveWaitlist() async {
    if (isWaitlisted) {
      setState(() {
        isWaitlisted = false;
      });

      // Get the selected event details
      var selectedEventDetails =
          events.firstWhere((event) => event['title'] == selectedEvent);

      // Get the current user's UID from FirebaseAuth
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Remove the selected event from the user's waiting list array
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'waitingList': FieldValue.arrayRemove([
          {
            'title': selectedEventDetails['title'],
            'posterUrl': selectedEventDetails['posterUrl'],
          },
        ])
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Waitlist Update".tr()),
          content:
              Text("${"You have left the waitlist for ".tr()}$selectedEvent."),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Waitlist".tr(), style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sold-Out Events".tr(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...events.map((event) {
              String eventTitle = event['title'];
              String eventImage = event['posterUrl'];
              return GestureDetector(
                onTap: () => setState(() => selectedEvent = eventTitle),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        eventImage,
                        height: 220,
                        width: 125,
                        fit: BoxFit.cover,
                      ),
                    ),
                    RadioListTile(
                      title: Text(eventTitle,
                          style: TextStyle(color: Colors.white)),
                      value: eventTitle,
                      groupValue: selectedEvent,
                      onChanged: (value) =>
                          setState(() => selectedEvent = value as String),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 40),
            Center(
              child: MaterialButton(
                onPressed: isWaitlisted ? leaveWaitlist : joinWaitlist,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                color: Color(0xFFffb43b),
                height: 70,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Center(
                    child: Text(
                      isWaitlisted
                          ? "Leave Waitlist".tr()
                          : "Join Waitlist".tr(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
