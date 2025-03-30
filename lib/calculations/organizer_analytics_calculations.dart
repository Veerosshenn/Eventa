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
      List<Map<String, dynamic>> eventRevenueList = [];

      for (var doc in eventSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String eventName = data['eventName'] ?? 'Unknown Event';

        // Extract booked seats
        List<String> bookedSeats = List<String>.from(data['ticketSetup']['bookedSeats'] ?? []);
        totalTicketsSold += bookedSeats.length;

        // Extract ticket setup
        Map<String, dynamic> ticketSetup = data['ticketSetup'] ?? {};

        // Parse ticket limits and prices
        int childLimit = int.tryParse(ticketSetup['child']?['limit']?.toString() ?? '0') ?? 0;
        double childPrice = double.tryParse(ticketSetup['child']?['price']?.toString() ?? '0') ?? 0.0;

        int generalLimit = int.tryParse(ticketSetup['generalAdmission']?['limit']?.toString() ?? '0') ?? 0;
        double generalPrice = double.tryParse(ticketSetup['generalAdmission']?['price']?.toString() ?? '0') ?? 0.0;

        int seniorLimit = int.tryParse(ticketSetup['seniorCitizen']?['limit']?.toString() ?? '0') ?? 0;
        double seniorPrice = double.tryParse(ticketSetup['seniorCitizen']?['price']?.toString() ?? '0') ?? 0.0;

        int vipLimit = int.tryParse(ticketSetup['vip']?['limit']?.toString() ?? '0') ?? 0;
        double vipPrice = double.tryParse(ticketSetup['vip']?['price']?.toString() ?? '0') ?? 0.0;

        // Calculate total available seats
        totalAvailableSeats += childLimit + generalLimit + seniorLimit + vipLimit;

        // Extract discount (percentage-based)
        double discountPercentage = 0;
        String? expiryDateString = ticketSetup['promo']?['expiryDate'];
        DateTime? expiry;
        if (expiryDateString != null) {
          try {
            expiry = DateTime.parse(expiryDateString);
            if (expiry.isAfter(DateTime.now())) {
              discountPercentage = double.tryParse(ticketSetup['promo']?['discount']?.toString() ?? '0') ?? 0.0;
            }
          } catch (e) {
            expiry = null;
          }
        }

        // Convert percentage discount to decimal
        double discountFactor = (100 - discountPercentage) / 100;

        // Count tickets sold per category
        int generalSold = bookedSeats.where((s) => s.startsWith('g-')).length;
        int seniorSold = bookedSeats.where((s) => s.startsWith('s-')).length;
        int vipSold = bookedSeats.where((s) => s.startsWith('v-')).length;
        int childSold = bookedSeats.where((s) => s.startsWith('c-')).length;

        // Apply percentage discount to each ticket category
        double revenueFromGeneral = generalSold * (generalPrice * discountFactor);
        double revenueFromSenior = seniorSold * (seniorPrice * discountFactor);
        double revenueFromVIP = vipSold * (vipPrice * discountFactor);
        double revenueFromChild = childSold * (childPrice * discountFactor);

        // Ensure revenue doesn't go negative (in case of extreme discounts)
        revenueFromGeneral = revenueFromGeneral < 0 ? 0 : revenueFromGeneral;
        revenueFromSenior = revenueFromSenior < 0 ? 0 : revenueFromSenior;
        revenueFromVIP = revenueFromVIP < 0 ? 0 : revenueFromVIP;
        revenueFromChild = revenueFromChild < 0 ? 0 : revenueFromChild;

        // Calculate total revenue correctly
        double eventRevenue = revenueFromGeneral + revenueFromSenior + revenueFromVIP + revenueFromChild;
        totalRevenue += eventRevenue;

        // Store event revenue for the bar chart
        eventRevenueList.add({
          "eventName": eventName,
          "revenue": eventRevenue.toStringAsFixed(2),
        });
      }

      // Seat occupancy calculation
      double seatOccupancy = (totalAvailableSeats > 0)
          ? (totalTicketsSold / totalAvailableSeats) * 100
          : (totalTicketsSold > 0 ? 100 : 0);

      return {
        "totalRevenue": totalRevenue.toStringAsFixed(2),
        "totalTicketsSold": totalTicketsSold,
        "seatOccupancy": seatOccupancy.toStringAsFixed(2),
        "eventRevenueList": eventRevenueList, 
      };
    } catch (e) {
      print("Error fetching analytics: $e");
      return {
        "totalRevenue": "0.00",
        "totalTicketsSold": 0,
        "seatOccupancy": "0",
        "eventRevenueList": [],
      };
    }
  }
}
