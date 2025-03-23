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
  List<Map<String, dynamic>> userWaitlist =
      []; // List to store the user's waitlist

  @override
  void initState() {
    super.initState();
    fetchEvents();
    fetchUserWaitlist();
  }

  void fetchEvents() async {
    FirebaseFirestore.instance.collection('events').get().then((snapshot) {
      setState(() {
        events = snapshot.docs
            .map((doc) => doc.data())
            .where((event) =>
                (event['ticketSetup']['bookedSeats'] as List).length == 4)
            .toList();
      });
    });
  }

  void fetchUserWaitlist() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists && doc.data() != null) {
        setState(() {
          userWaitlist =
              List<Map<String, dynamic>>.from(doc.data()!['waitingList'] ?? []);
        });
      }
    });
  }

  void joinWaitlist() async {
    if (selectedEvent != null) {
      setState(() {
        isWaitlisted = true;
      });

      // Get the selected event details
      var selectedEventDetails =
          events.firstWhere((event) => event['eventName'] == selectedEvent);

      // Get the current user's UID from FirebaseAuth
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Add the selected event to the user's waiting list array
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'waitingList': FieldValue.arrayUnion([
          {
            'title': selectedEventDetails['eventName'],
            'posterUrl': selectedEventDetails['posterUrl'],
          },
        ])
      }).then((_) {
        fetchUserWaitlist(); // Refresh the user's waitlist
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

  void leaveWaitlist(String eventTitle) async {
    setState(() {
      isWaitlisted = false;
    });

    // Get the current user's UID from FirebaseAuth
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Find the event from the user's waitlist with the corresponding title
    var eventToRemove =
        userWaitlist.firstWhere((event) => event['title'] == eventTitle);

    // Remove the selected event from the user's waiting list array
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'waitingList': FieldValue.arrayRemove([
        {
          'title': eventToRemove['title'],
          'posterUrl': eventToRemove['posterUrl'],
        },
      ])
    }).then((_) {
      fetchUserWaitlist(); // Refresh the user's waitlist
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Waitlist Update".tr()),
        content: Text("${"You have left the waitlist for ".tr()}$eventTitle."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Waitlist".tr(), style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Sold-Out Events".tr(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ...events.map((event) {
                String eventTitle = event['eventName'];
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
              MaterialButton(
                onPressed: joinWaitlist,
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
              SizedBox(height: 30),
              Text(
                "My Waitlist".tr(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (userWaitlist.isEmpty)
                Center(
                  child: Text("No events in your waitlist.".tr(),
                      style: TextStyle(color: Colors.white)),
                ),
              ...userWaitlist.map((event) {
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
                      const SizedBox(height: 30),
                      RadioListTile(
                        title: Text(eventTitle,
                            style: TextStyle(color: Colors.white)),
                        value: eventTitle,
                        groupValue: selectedEvent,
                        onChanged: (value) =>
                            setState(() => selectedEvent = value as String),
                      ),
                      const SizedBox(height: 30),
                      MaterialButton(
                        onPressed: () => leaveWaitlist(eventTitle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                        color: Color(0xFFffb43b),
                        height: 70,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60),
                          child: Center(
                            child: Text(
                              "Leave Waitlist".tr(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
