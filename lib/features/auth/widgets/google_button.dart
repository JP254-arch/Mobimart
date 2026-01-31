import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        padding: const EdgeInsets.all(12.0),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: const BorderSide(color: Colors.grey),
      ),
      icon: const Icon(Ionicons.logo_google, color: Colors.red),
      label: const Text(
        "Sign in with Google",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: onPressed,
    );
  }
}
