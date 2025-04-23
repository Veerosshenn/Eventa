import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../calculations/admin_analytics_calculations.dart';
import 'package:assignment1/pages/consts.dart';
import "package:easy_localization/easy_localization.dart";

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedTimeframe = "Weekly"; 
  final List<String> timeframes = ["Weekly", "Monthly", "Annual"];

  int _totalBookings = 0;
  int _eventsHosted = 0;
  double _utilizationRate = 0.0;
  Map<int, int> _eventsHostedOverTime = {};

  @override
  void initState() {
    super.initState();
    fetchAnalytics(); 
  }

  void fetchAnalytics() async {
    final analytics = AdminAnalyticsCalculations();

    int totalBookings = await analytics.getTotalBookings();
    int eventsHosted = await analytics.getEventsHosted();
    double utilizationRate = await analytics.getUtilizationRate(selectedTimeframe);
    Map<int, int> eventsHostedOverTime = await analytics.getEventsHostedOverTime(selectedTimeframe);

    setState(() {
      _totalBookings = totalBookings;
      _eventsHosted = eventsHosted;
      _utilizationRate = utilizationRate;
      _eventsHostedOverTime = eventsHostedOverTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text('Analytics Dashboard'.tr()),
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
            Text(
              "Select Timeframe".tr(),
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
                    fetchAnalytics();
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
                  _buildStatCard("Auditorium Bookings".tr(), _totalBookings.toString(), Icons.event_seat),
                  _buildStatCard("Events Hosted".tr(), _eventsHosted.toString(), Icons.calendar_today),
                  _buildStatCard("Utilization Rate".tr(), "${_utilizationRate.toStringAsFixed(2)}%", Icons.bar_chart),
                  const SizedBox(height: 20),
                  _buildBarChart(),
                  const SizedBox(height: 20),
                  _buildPieChart(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await generatePDF(
                      selectedTimeframe, 
                      _totalBookings, 
                      _eventsHosted, 
                      _utilizationRate, 
                      _eventsHostedOverTime
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("PDF generated successfully!".tr())),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error generating PDF: $e".tr())),
                    );
                  }
                },
                icon: const Icon(Icons.download, color: grey),
                label: Text("Download Report".tr()),
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
            "Events Hosted Over Time".tr(),
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
                        if (selectedTimeframe == "Weekly") {
                          List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                          return Text(days[value.toInt()], style: const TextStyle(color: Colors.white));
                        } else if (selectedTimeframe == "Monthly") {
                          return Text("Week ${(value.toInt() + 1)}", style: const TextStyle(color: Colors.white));
                        } else {
                          List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                          return Text(months[value.toInt()], style: const TextStyle(color: Colors.white));
                        }
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  selectedTimeframe == "Weekly" ? 7 : selectedTimeframe == "Monthly" ? 5 : 12,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (_eventsHostedOverTime[index] ?? 0).toDouble(),
                        color: buttonColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 300, // Increased height to accommodate the legend
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            "Utilization Rate".tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: _utilizationRate,
                    title: "${_utilizationRate.toStringAsFixed(1)}%",
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: Colors.grey,
                    value: 100 - _utilizationRate,
                    title: "${(100 - _utilizationRate).toStringAsFixed(1)}%",
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Legend Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blueAccent, "Utilized".tr()),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.grey, "Not Utilized".tr()),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to create legend items
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
