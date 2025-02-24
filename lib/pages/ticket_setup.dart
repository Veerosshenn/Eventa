import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';

class TicketSetupScreen extends StatefulWidget {
  const TicketSetupScreen({super.key});

  @override
  _TicketSetupScreenState createState() => _TicketSetupScreenState();
}

class _TicketSetupScreenState extends State<TicketSetupScreen> {
  final TextEditingController generalAdmissionController = TextEditingController();
  final TextEditingController vipController = TextEditingController();
  final TextEditingController seniorCitizenController = TextEditingController();
  final TextEditingController childPriceController = TextEditingController();
  final TextEditingController generalLimitController = TextEditingController();
  final TextEditingController vipLimitController = TextEditingController();
  final TextEditingController seniorLimitController = TextEditingController();
  final TextEditingController childLimitController = TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();
  final TextEditingController promoDiscountController = TextEditingController();

  String? selectedEvent;
  List<String> futureEvents = ["Tech Conference 2024", "Music Fest", "Business Expo"];

  // Seating Sections Assignment
  final Map<String, String?> seatingAssignments = {
    "CAT 1": null,
    "CAT 2": null,
    "CAT 3": null,
    "CAT 4": null,
    "CAT 5": null,
    "CAT 6": null
  };

  final List<String> ticketTypes = ["General Admission", "VIP", "Senior Citizen", "Child"];

  void _showSummaryDialog() {
    if (selectedEvent == null ||
        generalAdmissionController.text.isEmpty ||
        vipController.text.isEmpty ||
        seniorCitizenController.text.isEmpty ||
        childPriceController.text.isEmpty ||
        seatingAssignments.values.any((value) => value == null)) {  
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields and assign seating.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Ticket Setup", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem("Event:", selectedEvent!),
                const SizedBox(height: 10),
                const Text("Ticket Prices & Limits:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildSummaryItem("General Admission:", "RM ${generalAdmissionController.text} (${generalLimitController.text} max)"),
                _buildSummaryItem("VIP:", "RM ${vipController.text} (${vipLimitController.text} max)"),
                _buildSummaryItem("Senior Citizen:", "RM ${seniorCitizenController.text} (${seniorLimitController.text} max)"),
                _buildSummaryItem("Child:", "RM ${childPriceController.text} (${childLimitController.text} max)"),
                const SizedBox(height: 10),
                const Text("Seating Assignments:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...seatingAssignments.entries.map((entry) {
                  return _buildSummaryItem("${entry.key}:", entry.value ?? "Not assigned");
                }).toList(),
                if (promoCodeController.text.isNotEmpty && promoDiscountController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("Promotional Offers:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  _buildSummaryItem("Promo Code:", promoCodeController.text),
                  _buildSummaryItem("Discount:", "${promoDiscountController.text}%"),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel button
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveTicketSetup();
              },
              child: const Text("Confirm & Save"),
            ),
          ],
        );
      },
    );
  }

  void _saveTicketSetup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket Setup Saved Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: const Text('Ticket Setup'),
        backgroundColor: buttonColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown("Select Event", futureEvents, selectedEvent, (value) {
              setState(() {
                selectedEvent = value;
              });
            }),
            const SizedBox(height: 20),
            _buildTicketPricing(),
            const SizedBox(height: 20),
            _buildSeatingAssignment(),
            const SizedBox(height: 20),
            _buildPromoCodeSection(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showSummaryDialog,
                icon: const Icon(Icons.save, color: grey),
                label: const Text("Save Ticket Setup"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketPricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Set Ticket Prices & Limits",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        _buildPriceAndLimitField('General Admission', generalAdmissionController, generalLimitController),
        _buildPriceAndLimitField('VIP', vipController, vipLimitController),
        _buildPriceAndLimitField('Senior Citizen', seniorCitizenController, seniorLimitController),
        _buildPriceAndLimitField('Child', childPriceController, childLimitController),
      ],
    );
  }

  Widget _buildPriceAndLimitField(String label, TextEditingController priceController, TextEditingController limitController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "$label Price (RM)",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[800],
                prefixText: "RM ",
                prefixStyle: const TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "$label Max Tickets",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatingAssignment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assign Ticket Categories to Seating Sections",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Center(
          child: Image.asset(
            'assets/seating_layout.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: seatingAssignments.keys.map((section) {
            return _buildDropdown(section, ticketTypes, seatingAssignments[section], (value) {
              setState(() {
                seatingAssignments[section] = value;
              });
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPromoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Promotional Offers",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        _buildTextField('Promo Code', promoCodeController),
        _buildDiscountField('Discount Percentage', promoDiscountController),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[800],
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDiscountField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[800],
          suffixText: " %",
          suffixStyle: const TextStyle(color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$title $value", style: const TextStyle(fontSize: 16)),
    );
  }
}