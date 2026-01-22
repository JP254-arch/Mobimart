// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ✅ Proper route name
  static const String routeName = '/profile';

  // Mock user data
  final String userName = "John Doe";
  final String userEmail = "johndoe@example.com";
  final String userPhone = "+254700000000";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= USER INFO =================
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage('assets/images/user_placeholder.png'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(userEmail, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(userPhone, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ================= PROFILE OPTIONS =================
            _buildOption(
              context,
              icon: Icons.favorite_border,
              title: "Wishlist",
              subtitle: "View your favorite items",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              },
            ),
            const Divider(),

            _buildOption(
              context,
              icon: Icons.shopping_bag_outlined,
              title: "Orders",
              subtitle: "View your orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),
            const Divider(),

            _buildOption(
              context,
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "FAQs & Contact",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),
            const Divider(),

            _buildOption(
              context,
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "Read our policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER: Build ListTile Option =================
  Widget _buildOption(BuildContext context,
      {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }
}
