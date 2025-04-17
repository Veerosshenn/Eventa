import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../calculations/organizer_analytics_calculations.dart';
import 'package:assignment1/pages/consts.dart';
import "package:easy_localization/easy_localization.dart";

class OrganizerAnalyticsScreen extends StatefulWidget {
  final String userId;

  const OrganizerAnalyticsScreen({super.key, required this.userId});

  @override
  _OrganizerAnalyticsScreenState createState() => _OrganizerAnalyticsScreenState();
}

class _OrganizerAnalyticsScreenState extends State<OrganizerAnalyticsScreen> {
  String selectedTimeframe = "Weekly"; 
  final List<String> timeframes = ["Weekly", "Monthly", "Annual"];
  
  double _totalRevenue = 0.0;
  int _totalTicketsSold = 0;
  double _seatOccupancy = 0.0;
  List<Map<String, dynamic>> eventRevenueList = [];

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  void fetchAnalytics() async {
    try {
      final analytics = OrganizerAnalyticsCalculations();
      final result = await analytics.fetchAnalyticsOrganizerScreen(widget.userId, selectedTimeframe);

      if (result.isNotEmpty) {
        setState(() {
          _totalRevenue = double.tryParse(result["totalRevenue"].toString()) ?? 0.0;
          _totalTicketsSold = result["totalTicketsSold"] ?? 0;
          _seatOccupancy = double.tryParse(result["seatOccupancy"].toString()) ?? 0.0;
          eventRevenueList = result["eventRevenueList"] ?? [];
        });
      } else {
        print("No data received!");
      }
    } catch (e) {
      print("Error fetching analytics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text('Organizer Analytics'.tr()),
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
                  _buildStatCard("Total Revenue".tr(), "RM ${_totalRevenue.toStringAsFixed(2)}", Icons.monetization_on),
                  _buildStatCard("Tickets Sold".tr(), _totalTicketsSold.toString(), Icons.confirmation_number),
                  _buildStatCard("Seat Occupancy".tr(), "${_seatOccupancy.toStringAsFixed(2)}%", Icons.event_seat),
                  const SizedBox(height: 20),
                  _buildRevenueBarChart(eventRevenueList), 
                  const SizedBox(height: 20),
                  _buildSeatOccupancyPieChart(),
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
                      timeframe: selectedTimeframe,
                      totalRevenue: _totalRevenue,
                      totalTicketsSold: _totalTicketsSold,
                      seatOccupancy: _seatOccupancy,
                      eventRevenueList: eventRevenueList,
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

Widget _buildRevenueBarChart(List<Map<String, dynamic>> eventData) {
  if (eventData.isEmpty) {
    return Container(
      height: 250,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        "No revenue data available".tr(),
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

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
          "Revenue Overview".tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "RM ${value.toInt()}",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < eventData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            eventData[value.toInt()]['eventName'],
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white),
              ),
              barGroups: eventData.asMap().entries.map((entry) {
                int index = entry.key;
                double revenue = double.tryParse(entry.value['revenue'].toString()) ?? 0.0;
                return BarChartGroupData(
                  x: index,
                  barRods: [BarChartRodData(toY: revenue, color: Colors.greenAccent)],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildSeatOccupancyPieChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            "Seat Occupancy Breakdown".tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: Colors.greenAccent,
                    value: _seatOccupancy,
                    title: "${_seatOccupancy.toStringAsFixed(1)}%",
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: Colors.redAccent,
                    value: 100 - _seatOccupancy,
                    title: "${(100 - _seatOccupancy).toStringAsFixed(1)}%",
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.greenAccent, "Occupied".tr()),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.redAccent, "Vacant".tr()),
            ],
          ),
        ],
      ),
    );
  }
}

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
