import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsOrganizerScreen extends StatefulWidget {
  const AnalyticsOrganizerScreen({super.key});

  @override
  _AnalyticsOrganizerScreenState createState() => _AnalyticsOrganizerScreenState();
}

class _AnalyticsOrganizerScreenState extends State<AnalyticsOrganizerScreen> {
  String selectedTimeframe = "Monthly";
  final List<String> timeframes = ["Custom Range", "Weekly", "Monthly"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: const Text('Sales & Revenue Reports'),
        backgroundColor: buttonColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Timeframe",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.white),
              child: DropdownButtonFormField<String>(
                value: selectedTimeframe,
                items: timeframes.map((String timeframe) {
                  return DropdownMenuItem<String>(
                    value: timeframe,
                    child: Text(timeframe, style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTimeframe = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildStatCard("Total Revenue", "RM 125,000", Icons.attach_money),
                  _buildStatCard("Total Tickets Sold", "4,500", Icons.confirmation_number),
                  _buildStatCard("Seat Occupancy", "85%", Icons.event_seat),
                  const SizedBox(height: 20),
                  _buildBarChart(), // 📊 Ticket Sales Over Time
                  const SizedBox(height: 20),
                  _buildPieChart(), // 🥧 Seat Occupancy Breakdown
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, color: grey),
                label: const Text("Download Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: grey,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
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

  // 📊 Bar Chart for Ticket Sales
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
          const Text(
            "Monthly Ticket Sales",
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

  // 🥧 Pie Chart for Seat Occupancy
  Widget _buildPieChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            "Seat Occupancy Breakdown",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(color: Colors.greenAccent, value: 85, title: "Occupied", radius: 50),
                  PieChartSectionData(color: Colors.redAccent, value: 15, title: "Vacant", radius: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
