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
            SubmitButton(onPressed: () {
              // Handle registration logic here
            }),
          ],
        ),
      ),
    );
  }
}
