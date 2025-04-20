import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/widgets.dart' as pw;

class OrganizerAnalyticsCalculations {
  Future<Map<String, dynamic>> fetchAnalyticsOrganizerScreen(String userId, String timeframe) async {
    try {
      // Determine startDate based on timeframe
      DateTime now = DateTime.now();
      DateTime startDate;

      if (timeframe == "Weekly") {
        startDate = now.subtract(const Duration(days: 7));
      } else if (timeframe == "Monthly") {
        startDate = DateTime(now.year, now.month, 1);
      } else {
        startDate = DateTime(now.year, 1, 1);
      }

      // Fetch events based on createdBy and filtered by date
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

        // Skip if date is before the timeframe start
        String dateStr = data['date'];
        DateTime eventDate;
        try {
          eventDate = DateTime.parse(dateStr);
        } catch (e) {
          continue; // Skip events with invalid date
        }

        if (eventDate.isBefore(startDate)) continue;

        String eventName = data['eventName'] ?? 'Unknown Event';
        List<String> bookedSeats = List<String>.from(data['ticketSetup']['bookedSeats'] ?? []);
        totalTicketsSold += bookedSeats.length;

        Map<String, dynamic> ticketSetup = data['ticketSetup'] ?? {};

        int childLimit = int.tryParse(ticketSetup['child']?['limit']?.toString() ?? '0') ?? 0;
        double childPrice = double.tryParse(ticketSetup['child']?['price']?.toString() ?? '0') ?? 0.0;

        int generalLimit = int.tryParse(ticketSetup['generalAdmission']?['limit']?.toString() ?? '0') ?? 0;
        double generalPrice = double.tryParse(ticketSetup['generalAdmission']?['price']?.toString() ?? '0') ?? 0.0;

        int seniorLimit = int.tryParse(ticketSetup['seniorCitizen']?['limit']?.toString() ?? '0') ?? 0;
        double seniorPrice = double.tryParse(ticketSetup['seniorCitizen']?['price']?.toString() ?? '0') ?? 0.0;

        int vipLimit = int.tryParse(ticketSetup['vip']?['limit']?.toString() ?? '0') ?? 0;
        double vipPrice = double.tryParse(ticketSetup['vip']?['price']?.toString() ?? '0') ?? 0.0;

        totalAvailableSeats += childLimit + generalLimit + seniorLimit + vipLimit;

        double discountPercentage = 0;
        String? expiryDateString = ticketSetup['promo']?['expiryDate'];
        DateTime? expiry;
        if (expiryDateString != null) {
          try {
            expiry = DateTime.parse(expiryDateString);
            if (expiry.isAfter(now)) {
              discountPercentage = double.tryParse(ticketSetup['promo']?['discount']?.toString() ?? '0') ?? 0.0;
            }
          } catch (e) {
            expiry = null;
          }
        }

        double discountFactor = (100 - discountPercentage) / 100;

        int generalSold = bookedSeats.where((s) => s.startsWith('g-')).length;
        int seniorSold = bookedSeats.where((s) => s.startsWith('s-')).length;
        int vipSold = bookedSeats.where((s) => s.startsWith('v-')).length;
        int childSold = bookedSeats.where((s) => s.startsWith('c-')).length;

        double revenueFromGeneral = generalSold * (generalPrice * discountFactor);
        double revenueFromSenior = seniorSold * (seniorPrice * discountFactor);
        double revenueFromVIP = vipSold * (vipPrice * discountFactor);
        double revenueFromChild = childSold * (childPrice * discountFactor);

        revenueFromGeneral = revenueFromGeneral < 0 ? 0 : revenueFromGeneral;
        revenueFromSenior = revenueFromSenior < 0 ? 0 : revenueFromSenior;
        revenueFromVIP = revenueFromVIP < 0 ? 0 : revenueFromVIP;
        revenueFromChild = revenueFromChild < 0 ? 0 : revenueFromChild;

        double eventRevenue = revenueFromGeneral + revenueFromSenior + revenueFromVIP + revenueFromChild;
        totalRevenue += eventRevenue;

        eventRevenueList.add({
          "eventName": eventName,
          "revenue": eventRevenue.toStringAsFixed(2),
        });
      }

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

Future<void> generatePDF({
  required String timeframe,
  required double totalRevenue,
  required int totalTicketsSold,
  required double seatOccupancy,
  required List<Map<String, dynamic>> eventRevenueList,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Organizer Analytics Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Timeframe: $timeframe", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text("Total Revenue: RM ${totalRevenue.toStringAsFixed(2)}"),
              pw.Text("Total Tickets Sold: $totalTicketsSold"),
              pw.Text("Seat Occupancy: ${seatOccupancy.toStringAsFixed(2)}%"),
              pw.SizedBox(height: 20),
              pw.Text("Revenue per Event:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Event Name', 'Revenue (RM)'],
                data: eventRevenueList.map((event) {
                  return [
                    event['eventName'] ?? 'Unnamed',
                    event['revenue'] ?? '0.00',
                  ];
                }).toList(),
                border: pw.TableBorder.all(width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Convert PDF to bytes
  Uint8List pdfBytes = await pdf.save();

  if (kIsWeb) {
    // Web: Trigger file download
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "organizer_analytics_report.pdf")
      ..click();

    html.Url.revokeObjectUrl(url);
  } else {
    // Works on Android, iOS, Desktop
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/organizer_analytics_report.pdf';
    final file = File(filePath);

    await file.writeAsBytes(pdfBytes);
    await OpenFile.open(filePath);
  }
}