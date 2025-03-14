import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController promoExpiryController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedEvent;
  List<String> allEvents = [];
  bool isPromoEnabled = false;
  bool isPromoExpiryEnabled = false;

  final Map<String, bool> categoryAvailability = {
    "General Admission": true,
    "VIP": false,
    "Senior Citizen": false,
    "Child": false,
  };

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('events').get();
      setState(() {
        allEvents = querySnapshot.docs.map((doc) {
          return doc['eventName'] as String;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching events: $e')),
      );
    }
  }

  void _showSummaryDialog() {
    if (selectedEvent == null ||
      !(categoryAvailability['General Admission'] == true && generalAdmissionController.text.isNotEmpty ||
        categoryAvailability['VIP'] == true && vipController.text.isNotEmpty ||
        categoryAvailability['Senior Citizen'] == true && seniorCitizenController.text.isNotEmpty ||
        categoryAvailability['Child'] == true && childPriceController.text.isNotEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all required fields.')),
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
                const Text("Category Availability:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...categoryAvailability.entries.map((entry) {
                  return _buildSummaryItem("${entry.key}:", entry.value ? "Available" : "Locked");
                }).toList(),
                const SizedBox(height: 10),
                const Text("Ticket Prices & Limits:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildSummarySection(),
                if (promoCodeController.text.isNotEmpty && promoDiscountController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("Promotional Offers:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  _buildSummaryItem("Promo Code:", promoCodeController.text),
                  _buildSummaryItem("Discount:", "${promoDiscountController.text}%"),
                  if (promoExpiryController.text.isNotEmpty)
                    _buildSummaryItem("Expiry Date:", promoExpiryController.text),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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

  Future<void> _saveTicketSetup() async {
    try {
      String formattedEventId = selectedEvent?.replaceAll(' ', '_') ?? '';

      Map<String, dynamic> ticketData = {};
      
      void addTicketCategory(String category, TextEditingController priceController, TextEditingController limitController) {
        if (priceController.text.isNotEmpty && limitController.text.isNotEmpty) {
          ticketData[category] = {
            'price': priceController.text,
            'limit': limitController.text,
          };
        }
      }

      addTicketCategory('generalAdmission', generalAdmissionController, generalLimitController);
      addTicketCategory('vip', vipController, vipLimitController);
      addTicketCategory('seniorCitizen', seniorCitizenController, seniorLimitController);
      addTicketCategory('child', childPriceController, childLimitController);

      ticketData['categoryAvailability'] = categoryAvailability;

      if (promoCodeController.text.isNotEmpty && promoDiscountController.text.isNotEmpty) {
        ticketData['promo'] = {
          'code': promoCodeController.text,
          'discount': promoDiscountController.text,
          if (promoExpiryController.text.isNotEmpty) 'expiryDate': promoExpiryController.text,
        };
      }

      if (ticketData.isNotEmpty) {
        await _firestore.collection('events').doc(formattedEventId).update({
          'ticketSetup': ticketData,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket Setup Saved Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in at least one ticket category.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving ticket setup: $e')),
      );
    }
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
            _buildDropdown("Select Event", allEvents, selectedEvent, (value) {
              setState(() {
                selectedEvent = value;
              });
            }),
            const SizedBox(height: 20),
            _buildSeatingAssignment(),
            const SizedBox(height: 20),
            _buildTicketPricing(),
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
        if (categoryAvailability['General Admission'] ?? false)
          _buildPriceAndLimitField('General Admission', generalAdmissionController, generalLimitController),
        if (categoryAvailability['VIP'] ?? false)
          _buildPriceAndLimitField('VIP', vipController, vipLimitController),
        if (categoryAvailability['Senior Citizen'] ?? false)
          _buildPriceAndLimitField('Senior Citizen', seniorCitizenController, seniorLimitController),
        if (categoryAvailability['Child'] ?? false)
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
        "Manage Seating Availability",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 10),
      Column(
        children: categoryAvailability.keys.map((section) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Switch(
                value: categoryAvailability[section] ?? true,
                onChanged: (value) {
                  setState(() {
                    categoryAvailability[section] = value;
                  });
                },
              ),
            ],
          );
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Enable Promo Code",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Switch(
              value: isPromoEnabled,
              onChanged: (value) {
                setState(() {
                  isPromoEnabled = value;
                });
              },
            ),
          ],
        ),
        if (isPromoEnabled) ...[
          _buildTextField('Promo Code', promoCodeController),
          _buildDiscountField('Discount Percentage', promoDiscountController),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Enable Promo Expiry Date",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Switch(
                value: isPromoExpiryEnabled,
                onChanged: (value) {
                  setState(() {
                    isPromoExpiryEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isPromoExpiryEnabled)
            _buildDateTimeField(
              "Promo Expiry Date", 
              promoExpiryController, 
              _selectDate,
            ),
        ],
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

  Widget _buildSummarySection() {
    Map<String, TextEditingController> priceControllers = {
      "General Admission": generalAdmissionController,
      "VIP": vipController,
      "Senior Citizen": seniorCitizenController,
      "Child": childPriceController,
    };

    Map<String, TextEditingController> limitControllers = {
      "General Admission": generalLimitController,
      "VIP": vipLimitController,
      "Senior Citizen": seniorLimitController,
      "Child": childLimitController,
    };

    List<Widget> summaryItems = priceControllers.entries
        .where((entry) =>
            categoryAvailability[entry.key] == true &&
            entry.value.text.isNotEmpty &&
            limitControllers[entry.key]!.text.isNotEmpty)
        .map((entry) => _buildSummaryItem(
              "${entry.key}:",
              "RM ${entry.value.text} (${limitControllers[entry.key]!.text} max)",
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: summaryItems.isNotEmpty
          ? summaryItems
          : [const Text("No ticket categories selected.", style: TextStyle(color: Colors.white))],
    );
  }

  Widget _buildDateTimeField(String label, TextEditingController controller, Function(BuildContext) onTap) {
    return InkWell(
      onTap: () => onTap(context),
      child: IgnorePointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[800],
            suffixIcon: const Icon(Icons.calendar_today, color: buttonColor),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
    );
    if (pickedDate != null) {
      setState(() {
        promoExpiryController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
}