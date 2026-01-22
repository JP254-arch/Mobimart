import 'package:flutter/material.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String routeName = '/help-support';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          children: [
            // ================= HELP CENTER =================
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Help Center"),
              subtitle: const Text("FAQs & Contact Form"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpCenterScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // ================= PRIVACY POLICY =================
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text("Privacy Policy"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  PrivacyPolicyScreen.routeName,
                );
              },
            ),
            const Divider(),

            // ================= CONTACT SUPPORT =================
            ListTile(
              leading: const Icon(Icons.contact_support_outlined),
              title: const Text("Contact Support"),
              subtitle: const Text("Email or Chat"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Support feature coming soon"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= HELP CENTER SCREEN ================= */

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<Map<String, String>> faqs = [
    {
      "question": "How do I place an order?",
      "answer": "Select a product, add it to cart, and complete checkout."
    },
    {
      "question": "How do I track my order?",
      "answer": "Open Orders in your account to see tracking details."
    },
    {
      "question": "Can I cancel an order?",
      "answer": "Yes, orders can be cancelled before shipping."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...faqs.map(
              (faq) => ExpansionTile(
                title: Text(faq["question"]!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(faq["answer"]!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Contact Form",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(
                labelText: "Your Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Your Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Message sent successfully (mock)"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
