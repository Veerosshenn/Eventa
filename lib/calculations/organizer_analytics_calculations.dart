// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class OrganizerAnalyticsCalculations {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   Future<Map<String, dynamic>> fetchAnalyticsData(String currentUserId) async {
//     try {
//       print("Fetching data for user: $currentUserId");

//       final snapshot = await _firestore
//           .collection("events")
//           .where("createdBy", isEqualTo: currentUserId)
//           .get();

//       print("Total Events: ${snapshot.docs.length}");

//       if (snapshot.docs.isEmpty) {
//         print("No events found.");
//         return {
//           "revenue": 0.0,
//           "totalTicketsSold": 0,
//         };
//       }

//       double totalRevenue = 0.0;
//       int totalTicketsSold = 0;

//       for (var doc in snapshot.docs) {
//         final eventData = doc.data();
//         print("Event Data: $eventData");

//         final ticketData = eventData["ticketSetup"] ?? {};
//         print("Ticket Data: $ticketData");

//         ticketData.forEach((key, value) {
//           final price = double.tryParse(value["price"].toString()) ?? 0.0;
//           final sold = int.tryParse(value["sold"].toString()) ?? 0;

//           totalRevenue += price * sold;
//           totalTicketsSold += sold;
//         });
//       }

//       print("Total Revenue: $totalRevenue");
//       print("Total Tickets Sold: $totalTicketsSold");

//       return {
//         "revenue": totalRevenue,
//         "totalTicketsSold": totalTicketsSold,
//       };
//     } catch (e) {
//       print("Error fetching analytics data: $e");
//       return {
//         "revenue": 0.0,
//         "totalTicketsSold": 0,
//       };
//     }
//   }
// }