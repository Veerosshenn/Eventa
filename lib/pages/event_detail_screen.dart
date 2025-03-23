import 'package:easy_localization/easy_localization.dart';
import '../Widget/event_info.dart';
import 'consts.dart';
import 'ticket_booking_screen.dart';
import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailScreen({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: Text(
          "Event Detail".tr(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              SizedBox(
                height: 355,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Hero(
                      tag: eventData['posterUrl'],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          eventData['posterUrl'],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EventInfo(
                          icon: Icons.location_on,
                          name: "Location".tr(),
                          value: eventData['location'],
                        ),
                        EventInfo(
                          icon: Icons.lock_clock,
                          name: "Time".tr(),
                          value: eventData['startTime'],
                        ),
                        EventInfo(
                          icon: Icons.edit_calendar_outlined,
                          name: "Date".tr(),
                          value: eventData['date'],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                eventData['eventName'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Text(
                "Description".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 15),
              Text(
                eventData['description'],
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 2,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xff1c1c27),
                blurRadius: 60,
                spreadRadius: 80,
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            onPressed: () {},
            label: MaterialButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketBookingScreen(
                        eventData: eventData,
                      ),
                    ));
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: buttonColor,
              height: 70,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Center(
                  child: Text(
                    "Get Reservation".tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
