import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isObscure;
  final TextEditingController textEditingController;
  final String? userRole; // Optional user role

  const CustomTextField({
    super.key,
    required this.label,
    required this.textEditingController,
    this.isObscure = false,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: textEditingController,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: userRole != null ? '$label ($userRole)' : label, 
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
          fillColor: Colors.grey[800],
        ),
      ),
    );
  }
}
