import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'consts.dart';
import 'login.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterScreen extends StatefulWidget {
  final bool isTest;

  const RegisterScreen({super.key, this.isTest = false});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _registerUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      showError("All fields are required!".tr());
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isTest) {
        // ⛳ BYPASS registration logic in tests
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'role': 'user',
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration Successful! Please log in.".tr()),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Registration failed.".tr());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: Text("Register".tr(), style: TextStyle(color: grey)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCustomTextField(
                  emailController, "Email".tr(), const Key('emailField')),
              _buildCustomTextField(
                  nameController, "Name".tr(), const Key('nameField')),
              _buildCustomTextField(phoneController, "Phone Number".tr(),
                  const Key('phoneField'), TextInputType.phone),
              _buildCustomTextField(
                  passwordController,
                  "Password".tr(),
                  const Key('passwordField'),
                  TextInputType.visiblePassword,
                  true),
              const SizedBox(height: 25),
              ElevatedButton(
                key: const Key('registerButton'),
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFffb43b),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Register".tr(),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black),
                      ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Already have an account? Login".tr(),
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(
      TextEditingController controller, String label, Key fieldKey,
      [TextInputType keyboardType = TextInputType.text,
      bool isObscure = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        key: fieldKey,
        keyboardType: keyboardType,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          fillColor: grey,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
