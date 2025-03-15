import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

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
    "General Admission".tr(): true,
    "VIP".tr(): false,
    "Senior Citizen".tr(): false,
    "Child".tr(): false,
  };

  final Map<String, String> reverseCategoryTranslations = {
    "General Admission".tr(): "General Admission",
    "VIP".tr(): "VIP",
    "Senior Citizen".tr(): "Senior Citizen",
    "Child".tr(): "Child",
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
      !(categoryAvailability['General Admission'.tr()] == true && generalAdmissionController.text.isNotEmpty ||
        categoryAvailability['VIP'.tr()] == true && vipController.text.isNotEmpty ||
        categoryAvailability['Senior Citizen'.tr()] == true && seniorCitizenController.text.isNotEmpty ||
        categoryAvailability['Child'.tr()] == true && childPriceController.text.isNotEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in all required fields.'.tr())),
    );
    return;
  }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Ticket Setup".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem("Event:".tr(), selectedEvent!),
                const SizedBox(height: 10),
                Text("Category Availability:".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...categoryAvailability.entries.map((entry) {
                  return _buildSummaryItem("${entry.key}:", entry.value ? "Available".tr() : "Locked".tr());
                }).toList(),
                const SizedBox(height: 10),
                Text("Ticket Prices & Limits:".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildSummarySection(),
                if (promoCodeController.text.isNotEmpty && promoDiscountController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text("Promotional Offers:".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  _buildSummaryItem("Promo Code:".tr(), promoCodeController.text),
                  _buildSummaryItem("Discount:".tr(), "${promoDiscountController.text}%"),
                  if (promoExpiryController.text.isNotEmpty)
                    _buildSummaryItem("Expiry Date:".tr(), promoExpiryController.text),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel".tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveTicketSetup();
              },
              child: Text("Confirm & Save".tr()),
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

      // Convert translated keys back to English before saving
      Map<String, bool> convertedCategoryAvailability = {};

      categoryAvailability.forEach((translatedKey, value) {
        String englishKey = reverseCategoryTranslations[translatedKey] ?? translatedKey;
        convertedCategoryAvailability[englishKey] = value;
      });

      ticketData['categoryAvailability'] = convertedCategoryAvailability;

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
          SnackBar(
            content: Text('Ticket Setup Saved Successfully!'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in at least one ticket category.'.tr()),
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
        title: Text('Ticket Setup'.tr()),
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
            _buildDropdown("Select Event".tr(), allEvents, selectedEvent, (value) {
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
                label: Text("Save Ticket Setup".tr()),
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
        Text(
          "Set Ticket Prices & Limits".tr(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        if (categoryAvailability['General Admission'.tr()] ?? false)
          _buildPriceAndLimitField('General Admission'.tr(), generalAdmissionController, generalLimitController),
        if (categoryAvailability['VIP'.tr()] ?? false)
          _buildPriceAndLimitField('VIP'.tr(), vipController, vipLimitController),
        if (categoryAvailability['Senior Citizen'.tr()] ?? false)
          _buildPriceAndLimitField('Senior Citizen'.tr(), seniorCitizenController, seniorLimitController),
        if (categoryAvailability['Child'.tr()] ?? false)
          _buildPriceAndLimitField('Child'.tr(), childPriceController, childLimitController),
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
      Text(
        "Manage Seating Availability".tr(),
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
        Text(
          "Promotional Offers".tr(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Enable Promo Code".tr(),
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
          _buildTextField('Promo Code'.tr(), promoCodeController),
          _buildDiscountField('Discount Percentage'.tr(), promoDiscountController),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Enable Promo Expiry Date".tr(),
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
              "Promo Expiry Date".tr(), 
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
      "General Admission".tr(): generalAdmissionController,
      "VIP".tr(): vipController,
      "Senior Citizen".tr(): seniorCitizenController,
      "Child".tr(): childPriceController,
    };

    Map<String, TextEditingController> limitControllers = {
      "General Admission".tr(): generalLimitController,
      "VIP".tr(): vipLimitController,
      "Senior Citizen".tr(): seniorLimitController,
      "Child".tr(): childLimitController,
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
          : [Text("No ticket categories selected.".tr(), style: TextStyle(color: Colors.white))],
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