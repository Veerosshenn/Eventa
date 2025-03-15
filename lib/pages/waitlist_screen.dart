import 'consts.dart';
import 'main_screen.dart';
import 'package:flutter/material.dart';

class WaitlistScreen extends StatefulWidget {
  @override
  _WaitlistScreenState createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  String? selectedEvent;
  bool isWaitlisted = false;

  void joinWaitlist() {
    if (selectedEvent != null) {
      setState(() {
        isWaitlisted = true;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Waitlist Confirmation"),
          content:
              Text("You have been added to the waitlist for $selectedEvent."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void leaveWaitlist() {
    if (isWaitlisted) {
      setState(() {
        isWaitlisted = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Waitlist Update"),
          content: Text("You have left the waitlist for $selectedEvent."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("OK"),
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
        title: Text("Waitlist", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sold-Out Events",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () =>
                  setState(() => selectedEvent = "CV Writing Techniques"),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/cv_writing.jpeg",
                      height: 220,
                      width: 125,
                      fit: BoxFit.cover,
                    ),
                  ),
                  RadioListTile(
                    title: Text("CV Writing Techniques",
                        style: TextStyle(color: Colors.white)),
                    value: "CV Writing Techniques",
                    groupValue: selectedEvent,
                    onChanged: (value) =>
                        setState(() => selectedEvent = value as String),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => selectedEvent = "Bouldering is Fun"),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/bouldering.jpeg",
                      height: 220,
                      width: 125,
                      fit: BoxFit.cover,
                    ),
                  ),
                  RadioListTile(
                    title: Text("Bouldering is Fun",
                        style: TextStyle(color: Colors.white)),
                    value: "Bouldering is Fun",
                    groupValue: selectedEvent,
                    onChanged: (value) =>
                        setState(() => selectedEvent = value as String),
                  ),
                ],
              ),
            ),
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
                      isWaitlisted ? "Leave Waitlist" : "Join Waitlist",
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
