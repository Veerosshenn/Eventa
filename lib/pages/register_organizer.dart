import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import '../Widget/custom_text_field.dart';
import '../Widget/submit_button.dart';

class RegisterOrganizerScreen extends StatefulWidget {
  const RegisterOrganizerScreen({super.key});

  @override
  _RegisterOrganizerScreenState createState() => _RegisterOrganizerScreenState();
}

class _RegisterOrganizerScreenState extends State<RegisterOrganizerScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController orgNameController = TextEditingController();

  void _showConfirmationDialog() {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Registration"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryItem("Full Name:", fullNameController.text),
              _buildSummaryItem("Email:", emailController.text),
              _buildSummaryItem("Phone:", phoneController.text),
              if (orgNameController.text.isNotEmpty) _buildSummaryItem("Organization:", orgNameController.text),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                _registerOrganizer();
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _registerOrganizer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Organizer registered successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: const Text('Register Organizer'),
        backgroundColor: buttonColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: grey),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(label: 'Full Name', textEditingController: fullNameController),
            CustomTextField(label: 'Email', textEditingController: emailController),
            CustomTextField(label: 'Phone Number', textEditingController: phoneController),
            CustomTextField(label: 'Organization Name (If Applicable)', textEditingController: orgNameController),
            const SizedBox(height: 20),
            SubmitButton(onPressed: _showConfirmationDialog),
          ],
        ),
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
