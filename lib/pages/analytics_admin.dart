import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedTimeframe = "Monthly"; 
  final List<String> timeframes = ["Custom Range", "Weekly", "Monthly"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
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
                  _buildStatCard("Auditorium Bookings", "25", Icons.event_seat),
                  _buildStatCard("Events Hosted", "10", Icons.calendar_today),
                  _buildStatCard("Utilization Rate", "75%", Icons.bar_chart),
                  const SizedBox(height: 20),
                  _buildBarChart(), // 📊 Bar Chart
                  const SizedBox(height: 20),
                  _buildPieChart(), // 🥧 Pie Chart
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

  // 📊 Bar Chart for Event Trends
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
            "Events Hosted Over Time",
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
                        switch (value.toInt()) {
                          case 0: return const Text("Jan", style: TextStyle(color: Colors.white));
                          case 1: return const Text("Feb", style: TextStyle(color: Colors.white));
                          case 2: return const Text("Mar", style: TextStyle(color: Colors.white));
                          case 3: return const Text("Apr", style: TextStyle(color: Colors.white));
                          case 4: return const Text("May", style: TextStyle(color: Colors.white));
                          case 5: return const Text("Jun", style: TextStyle(color: Colors.white));
                          case 6: return const Text("Jul", style: TextStyle(color: Colors.white));
                          case 7: return const Text("Aug", style: TextStyle(color: Colors.white));
                          case 8: return const Text("Sep", style: TextStyle(color: Colors.white));
                          case 9: return const Text("Oct", style: TextStyle(color: Colors.white));
                          case 10: return const Text("Nov", style: TextStyle(color: Colors.white));
                          case 11: return const Text("Dec", style: TextStyle(color: Colors.white));
                          default: return Container();
                        }
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: buttonColor)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: buttonColor)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5, color: buttonColor)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8, color: buttonColor)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 12, color: buttonColor)]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 5, color: buttonColor)]),
                  BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 8, color: buttonColor)]),
                  BarChartGroupData(x: 7, barRods: [BarChartRodData(toY: 12, color: buttonColor)]),
                  BarChartGroupData(x: 8, barRods: [BarChartRodData(toY: 5, color: buttonColor)]),
                  BarChartGroupData(x: 9, barRods: [BarChartRodData(toY: 8, color: buttonColor)]),
                  BarChartGroupData(x: 10, barRods: [BarChartRodData(toY: 12, color: buttonColor)]),
                  BarChartGroupData(x: 11, barRods: [BarChartRodData(toY: 5, color: buttonColor)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🥧 Pie Chart for Utilization Stats
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
            "Utilization Breakdown",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(color: Colors.blueAccent, value: 50, title: "50%", radius: 50),
                  PieChartSectionData(color: Colors.redAccent, value: 30, title: "30%", radius: 50),
                  PieChartSectionData(color: Colors.greenAccent, value: 20, title: "20%", radius: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
