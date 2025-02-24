import 'package:flutter/material.dart';
import '../Widget/custom_text_field.dart';
import '../Widget/submit_button.dart';
import 'home_admin.dart';
import 'home_organizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "admin" && password == "123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin(userRole: 'admin')),
      );
    } else if (email == "organizer" && password == "123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeOrganizer(userRole: 'organizer')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Eventa",
              style: TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold,
                color: Colors.redAccent, 
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(label: 'Email', textEditingController: emailController),
            CustomTextField(label: 'Password', isObscure: true, textEditingController: passwordController),
            const SizedBox(height: 20),
            SubmitButton(onPressed: _login),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
