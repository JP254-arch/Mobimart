// lib/features/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mobimart Privacy Policy",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "At Mobimart, your privacy is very important to us. We are committed to protecting your personal information and ensuring a safe shopping experience.",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _sectionTitle("1. Information Collection", textTheme, colorScheme),
            _sectionText(
              "We collect only the information necessary to process your orders, manage your account, and improve your experience.",
              textTheme,
              colorScheme,
            ),

            _sectionTitle("2. Use of Information", textTheme, colorScheme),
            _sectionText(
              "Your personal data is used only for order processing, customer support, and improving Mobimart services.",
              textTheme,
              colorScheme,
            ),

            _sectionTitle("3. Sharing of Information", textTheme, colorScheme),
            _sectionText(
              "Mobimart does not share your personal data with third parties without your consent, except when required by law.",
              textTheme,
              colorScheme,
            ),

            _sectionTitle("4. Security", textTheme, colorScheme),
            _sectionText(
              "We implement industry-standard security measures to protect your data against unauthorized access, disclosure, or modification.",
              textTheme,
              colorScheme,
            ),

            _sectionTitle("5. Cookies and Tracking", textTheme, colorScheme),
            _sectionText(
              "Mobimart may use cookies and analytics tools to improve website and app performance.",
              textTheme,
              colorScheme,
            ),

            _sectionTitle("6. Changes to This Policy", textTheme, colorScheme),
            _sectionText(
              "We may update this Privacy Policy from time to time. Any changes will be communicated via the app.",
              textTheme,
              colorScheme,
            ),

            _sectionTitle("7. Contact Us", textTheme, colorScheme),
            _sectionText(
              "If you have questions about this Privacy Policy or your personal data, you can contact Mobimart support.",
              textTheme,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _sectionText(
    String text,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      ),
    );
  }
}
