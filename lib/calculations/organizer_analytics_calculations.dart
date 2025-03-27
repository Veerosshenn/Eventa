import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerAnalyticsCalculations {
  Future<Map<String, dynamic>> fetchAnalyticsOrganizerScreen(String userId) async {
    try {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('createdBy', isEqualTo: userId)
          .get();

      double totalRevenue = 0;
      int totalTicketsSold = 0;
      int totalAvailableSeats = 0;

      for (var doc in eventSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        List<String> bookedSeats = List<String>.from(data['bookedSeats'] ?? []);
        totalTicketsSold += bookedSeats.length;

        Map<String, dynamic> ticketSetup = data['ticketSetup'] ?? {};
        int generalLimit = int.parse(ticketSetup['generalAdmission']['limit'] ?? '0');
        double generalPrice = double.parse(ticketSetup['generalAdmission']['price'] ?? '0');

        int seniorLimit = int.parse(ticketSetup['seniorCitizen']['limit'] ?? '0');
        double seniorPrice = double.parse(ticketSetup['seniorCitizen']['price'] ?? '0');

        int vipLimit = int.parse(ticketSetup['vip']['limit'] ?? '0');
        double vipPrice = double.parse(ticketSetup['vip']['price'] ?? '0');

        int childLimit = int.parse(ticketSetup['child']['limit'] ?? '0');
        double childPrice = double.parse(ticketSetup['child']['price'] ?? '0');

        totalAvailableSeats += generalLimit + seniorLimit + vipLimit + childLimit;

        double discount = 0;
        if (ticketSetup.containsKey('promo')) {
          DateTime expiry = DateTime.parse(ticketSetup['promo']['expiryDate']);
          if (expiry.isAfter(DateTime.now())) {
            discount = double.parse(ticketSetup['promo']['discount'] ?? '0');
          }
        }

        int generalSold = bookedSeats.where((s) => s.startsWith('g-')).length;
        int seniorSold = bookedSeats.where((s) => s.startsWith('s-')).length;
        int vipSold = bookedSeats.where((s) => s.startsWith('v-')).length;
        int childSold = bookedSeats.where((s) => s.startsWith('c-')).length;

        totalRevenue += (generalSold * generalPrice) +
            (seniorSold * seniorPrice) +
            (vipSold * vipPrice) +
            (childSold * childPrice);
        totalRevenue -= discount;
      }

      double seatOccupancy = totalAvailableSeats > 0
          ? (totalTicketsSold / totalAvailableSeats) * 100
          : 0;

      return {
        "totalRevenue": totalRevenue.toStringAsFixed(2),
        "totalTicketsSold": totalTicketsSold,
        "seatOccupancy": seatOccupancy.toStringAsFixed(2),
      };
    } catch (e) {
      print("Error fetching analytics: $e");
      return {"totalRevenue": "0.00", "totalTicketsSold": 0, "seatOccupancy": "0"};
    }
  }
}
