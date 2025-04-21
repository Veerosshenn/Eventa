import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:assignment1/pages/consts.dart';
import '../Widget/custom_text_field.dart';
import '../Widget/submit_button.dart';
import 'home_admin.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterOrganizerScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const RegisterOrganizerScreen({super.key, this.auth, this.firestore});

  @override
  _RegisterOrganizerScreenState createState() => _RegisterOrganizerScreenState();
}

class _RegisterOrganizerScreenState extends State<RegisterOrganizerScreen> {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController orgNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? FirebaseAuth.instance;
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
  }
  
  void _showConfirmationDialog() {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields.'.tr())),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Registration".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryItem("Full Name:".tr(), fullNameController.text),
              _buildSummaryItem("Email:".tr(), emailController.text),
              _buildSummaryItem("Phone:".tr(), phoneController.text),
              if (orgNameController.text.isNotEmpty) _buildSummaryItem("Organization:".tr(), orgNameController.text),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Cancel".tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _registerOrganizer();
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              child: Text("Confirm".tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerOrganizer() async {
    try {
      String tempPassword = "temp123";

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: tempPassword,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'fullName': fullNameController.text.trim(),
        
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'organization': orgNameController.text.trim(),
        'role': 'organizer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _auth.sendPasswordResetEmail(email: emailController.text.trim());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin(userRole: 'admin')),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Organizer registered successfully! Instructions to reset the password has been sent to the email.'.tr()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text('Register Organizer'.tr()),
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
            CustomTextField(label: 'Full Name'.tr(), textEditingController: fullNameController),
            CustomTextField(label: 'Email'.tr(), textEditingController: emailController),
            CustomTextField(label: 'Phone Number'.tr(), textEditingController: phoneController),
            CustomTextField(label: 'Organization Name (If Applicable)'.tr(), textEditingController: orgNameController),
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
