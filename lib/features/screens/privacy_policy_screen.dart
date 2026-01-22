import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Mobimart Privacy Policy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            Text(
              "At Mobimart, your privacy is very important to us. We are committed to protecting your personal information and ensuring a safe shopping experience.",
            ),
            SizedBox(height: 16),

            Text(
              "1. Information Collection",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "We collect only the information necessary to process your orders, manage your account, and improve your experience.",
            ),
            SizedBox(height: 12),

            Text(
              "2. Use of Information",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Your personal data is used only for order processing, customer support, and improving Mobimart services.",
            ),
            SizedBox(height: 12),

            Text(
              "3. Sharing of Information",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Mobimart does not share your personal data with third parties without your consent, except when required by law.",
            ),
            SizedBox(height: 12),

            Text(
              "4. Security",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "We implement industry-standard security measures to protect your data against unauthorized access, disclosure, or modification.",
            ),
            SizedBox(height: 12),

            Text(
              "5. Cookies and Tracking",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Mobimart may use cookies and analytics tools to improve website and app performance.",
            ),
            SizedBox(height: 12),

            Text(
              "6. Changes to This Policy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "We may update this Privacy Policy from time to time. Any changes will be communicated via the app.",
            ),
            SizedBox(height: 12),

            Text(
              "7. Contact Us",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "If you have questions about this Privacy Policy or your personal data, you can contact Mobimart support.",
            ),
          ],
        ),
      ),
    );
  }
}
