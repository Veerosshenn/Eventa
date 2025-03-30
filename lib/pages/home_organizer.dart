import 'consts.dart';
import 'package:flutter/material.dart';
import 'create_event.dart';
import 'analytics_organizer.dart';
import 'login.dart';
import 'ticket_setup.dart';
import 'edit_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeOrganizer extends StatefulWidget {
  final String userRole;

  const HomeOrganizer({super.key, required this.userRole});

  @override
  _HomeOrganizerState createState() => _HomeOrganizerState();
}

class _HomeOrganizerState extends State<HomeOrganizer> {
  String userName = "Organizer";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = 
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "Organizer";
          userId = user.uid;
        });
      }
    }
  }

  void _signOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text('Organizer Dashboard'.tr()),
        backgroundColor: buttonColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: grey),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'welcome_user'.tr(namedArgs: {'userName': userName}),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    context,
                    title: 'Event Creation'.tr(),
                    icon: Icons.event,
                    screen: CreateEventScreen(userId: userId),
                  ),
                  _buildCard(
                    context,
                    title: 'Edit Events'.tr(),
                    icon: Icons.event_note,
                    screen: EditEventScreen(userId: userId),
                  ),
                  _buildCard(
                    context,
                    title: 'Ticket Setup'.tr(),
                    icon: Icons.monetization_on,
                    screen: const TicketSetupScreen(),
                  ),
                  _buildCard(
                    context,
                    title: 'View Analytics'.tr(),
                    icon: Icons.bar_chart,
                    screen: OrganizerAnalyticsScreen(userId: userId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required Widget screen}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: grey),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
