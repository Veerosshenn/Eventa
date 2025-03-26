// import 'package:flutter/material.dart';
// import 'consts.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:assignment1/calculations/organizer_analytics_calculations.dart';

// class AnalyticsOrganizerScreen extends StatefulWidget {
//   final String userId;
//   const AnalyticsOrganizerScreen({super.key, required this.userId});

//   @override
//   _AnalyticsOrganizerScreenState createState() => _AnalyticsOrganizerScreenState();
// }

// class _AnalyticsOrganizerScreenState extends State<AnalyticsOrganizerScreen> {
//   final OrganizerAnalyticsCalculations _analytics = OrganizerAnalyticsCalculations();
//   Map<String, dynamic> analyticsData = {"totalRevenue": "0.00", "totalTicketsSold": 0, "seatOccupancy": "0"};

//   @override
//   void initState() {
//     super.initState();
//     _fetchAnalytics();
//   }

//   Future<void> _fetchAnalytics() async {
//     var data = await _analytics.fetchAnalyticsOrganizerScreen(widget.userId);
//     setState(() {
//       analyticsData = data;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: appBackgroundColor,
//       appBar: AppBar(
//         title: Text('Analytics Dashboard'.tr()),
//         backgroundColor: buttonColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: grey),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Select Timeframe".tr(),
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const SizedBox(height: 10),
//             Theme(
//               data: Theme.of(context).copyWith(canvasColor: Colors.white),
//               child: DropdownButtonFormField<String>(
//                 value: selectedTimeframe,
//                 items: timeframes.map((String timeframe) {
//                   return DropdownMenuItem<String>(
//                     value: timeframe,
//                     child: Text(timeframe, style: const TextStyle(color: Colors.black)),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedTimeframe = value!;
//                     fetchAnalytics();
//                   });
//                 },
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildStatCard("Auditorium Bookings".tr(), _totalBookings.toString(), Icons.event_seat),
//                   _buildStatCard("Events Hosted".tr(), _eventsHosted.toString(), Icons.calendar_today),
//                   _buildStatCard("Utilization Rate".tr(), "${_utilizationRate.toStringAsFixed(2)}%", Icons.bar_chart),
//                   const SizedBox(height: 20),
//                   _buildBarChart(),
//                   const SizedBox(height: 20),
//                   _buildPieChart(),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () async {
//                   await generatePDF(selectedTimeframe, _totalBookings, _eventsHosted, _utilizationRate, _eventsHostedOverTime);
//                 },
//                 icon: const Icon(Icons.download, color: grey),
//                 label: Text("Download Report".tr()),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: buttonColor,
//                   foregroundColor: grey,
//                   padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildRevenueBarChart(double revenue) {
//     return Container(
//       height: 250,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white12,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         children: [
//           Text(
//             "Revenue Overview".tr(),
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: BarChart(
//               BarChartData(
//                 gridData: const FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         return Text("RM ${value.toInt() * 500}", style: const TextStyle(color: Colors.white));
//                       },
//                     ),
//                   ),
//                 ),
//                 barGroups: [
//                   BarChartGroupData(
//                     x: 1,
//                     barRods: [BarChartRodData(toY: revenue, color: Colors.greenAccent)],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildSeatOccupancyPieChart(double occupancy) {
//     return Container(
//       height: 250,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white12,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         children: [
//           Text(
//             "Seat Occupancy Breakdown".tr(),
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: PieChart(
//               PieChartData(
//                 sectionsSpace: 2,
//                 centerSpaceRadius: 50,
//                 sections: [
//                   PieChartSectionData(color: Colors.greenAccent, value: occupancy, title: "Occupied", radius: 50),
//                   PieChartSectionData(color: Colors.redAccent, value: 100 - occupancy, title: "Vacant", radius: 50),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
