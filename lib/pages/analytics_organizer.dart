import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
// import '../calculations/organizer_analytics_calculations.dart';

class AnalyticsOrganizerScreen extends StatefulWidget {
  final String userId;
  const AnalyticsOrganizerScreen({super.key, required this.userId});

  @override
  _AnalyticsOrganizerScreenState createState() => _AnalyticsOrganizerScreenState();
}

class _AnalyticsOrganizerScreenState extends State<AnalyticsOrganizerScreen> {
  late Future<Map<String, dynamic>> analyticsData;

  // @override
  // void initState() {
  //   super.initState();
  //   analyticsData = OrganizerAnalyticsCalculations().fetchAnalyticsData(widget.userId);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text('Sales & Revenue Reports').tr(),
        backgroundColor: buttonColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: analyticsData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error loading data".tr(), style: TextStyle(color: Colors.white)));
            }

            var data = snapshot.data ?? {};

            return ListView(
              children: [
                _buildStatCard("Total Revenue".tr(), "RM ${data['totalRevenue']}", Icons.attach_money),
                _buildStatCard("Total Tickets Sold".tr(), "${data['totalTicketsSold']}", Icons.confirmation_number),
                _buildStatCard("Seat Occupancy".tr(), "${data['seatOccupancy']}%", Icons.event_seat),
                const SizedBox(height: 20),
                _buildBarChart(),
                const SizedBox(height: 20),
                _buildPieChart(data['seatOccupancy']),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 40, color: buttonColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            "Monthly Ticket Sales".tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                        return Text(months[value.toInt()], style: const TextStyle(color: Colors.white));
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(12, (index) => BarChartGroupData(
                  x: index, 
                  barRods: [BarChartRodData(toY: (index + 1) * 500.0, color: buttonColor)]
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(double occupancy) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            "Seat Occupancy Breakdown".tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(color: Colors.greenAccent, value: occupancy, title: "Occupied", radius: 50),
                  PieChartSectionData(color: Colors.redAccent, value: 100 - occupancy, title: "Vacant", radius: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
