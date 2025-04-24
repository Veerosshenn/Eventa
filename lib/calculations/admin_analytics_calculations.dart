import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/widgets.dart' as pw;

class AdminAnalyticsCalculations {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalBookings() async {
    QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();
    return eventsSnapshot.docs.length;
  }

  Future<int> getEventsHosted() async {
    QuerySnapshot eventsSnapshot = await _firestore
        .collection('events')
        .where('date', isLessThan: DateTime.now().toString())
        .get();
    return eventsSnapshot.docs.length;
  }

  Future<double> getUtilizationRate(String timeframe) async {
    DateTime now = DateTime.now();
    DateTime startDate;

    if (timeframe == "Weekly") {
      startDate = now.subtract(const Duration(days: 7)); 
    } else if (timeframe == "Monthly") {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, 1, 1); 
    }

    QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();
    int totalBookings = eventsSnapshot.docs
        .where((doc) => DateTime.parse(doc['date']).isAfter(startDate))
        .length;

    int totalDaysAvailable;
    if (timeframe == "Weekly") {
      totalDaysAvailable = 7;
    } else if (timeframe == "Monthly") {
      totalDaysAvailable = DateTime(now.year, now.month + 1, 0).day;
    } else {
      totalDaysAvailable = 365;
    }

    double utilizationRate = (totalBookings / totalDaysAvailable) * 100;
    return utilizationRate.clamp(0, 100);
  }

  Future<Map<int, int>> getEventsHostedOverTime(String timeframe) async {
    DateTime now = DateTime.now();
    DateTime startDate;

    if (timeframe == "Weekly") {
      startDate = now.subtract(const Duration(days: 7)); 
    } else if (timeframe == "Monthly") {
      startDate = DateTime(now.year, now.month, 1); 
    } else {
      startDate = DateTime(now.year, 1, 1); 
    }

    QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();
    Map<int, int> eventsHostedOverTime = {};

    for (var doc in eventsSnapshot.docs) {
      String dateString = doc['date'];
      DateTime eventDate = DateTime.parse(dateString);

      if (eventDate.isAfter(startDate)) {
        if (timeframe == "Weekly") {
          // Group events by day of the week (0 = Monday, 6 = Sunday)
          int dayIndex = eventDate.weekday - 1;
          eventsHostedOverTime[dayIndex] = (eventsHostedOverTime[dayIndex] ?? 0) + 1;
        } else if (timeframe == "Monthly") {
          // Group events by week of the month
          int weekIndex = ((eventDate.day - 1) ~/ 7) + 1;
          eventsHostedOverTime[weekIndex] = (eventsHostedOverTime[weekIndex] ?? 0) + 1;
        } else {
          // Group events by month (0 = Jan, 11 = Dec)
          int monthIndex = eventDate.month - 1;
          eventsHostedOverTime[monthIndex] = (eventsHostedOverTime[monthIndex] ?? 0) + 1;
        }
      }
    }

    return eventsHostedOverTime;
  }
}

Future<void> generatePDF(
  String timeframe,
  int totalBookings,
  int eventsHosted,
  double utilizationRate,
  Map<int, int> eventsHostedOverTime,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Admin Analytics Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Timeframe: $timeframe", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text("Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Bullet(text: "Total Bookings: $totalBookings"),
              pw.Bullet(text: "Events Hosted: $eventsHosted"),
              pw.Bullet(text: "Utilization Rate: ${utilizationRate.toStringAsFixed(2)}%"),
              pw.SizedBox(height: 20),
              pw.Text("Monthly Events Breakdown", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Month', 'Number of Events'],
                data: eventsHostedOverTime.entries.map((entry) {
                  return [
                    "Month ${entry.key + 1}",
                    entry.value.toString(),
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
      ..setAttribute("download", "admin_analytics_report.pdf")
      ..click();

    html.Url.revokeObjectUrl(url);
  } else {
    // Works on Android, iOS, Desktop
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/admin_analytics_report.pdf';
    final file = File(filePath);

    await file.writeAsBytes(pdfBytes);
    await OpenFile.open(filePath);
  }
}