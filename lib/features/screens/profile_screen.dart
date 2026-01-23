// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          userName = data['name'] ?? '';
          userEmail = data['email'] ?? user!.email ?? '';
          userPhone = data['phone'] ?? '';
          userPhotoUrl = data['photoUrl'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    backgroundImage: (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                        ? NetworkImage(userPhotoUrl!)
                        : const AssetImage('assets/images/user_placeholder.png') as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName.isNotEmpty ? userName : 'Loading...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail.isNotEmpty ? userEmail : '-',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userPhone.isNotEmpty ? userPhone : '-',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, SettingsScreen.routeName);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              ),
            ),
            const Divider(),
            _buildOption(
              context,
              icon: Icons.shopping_bag_outlined,
              title: "Orders",
              subtitle: "View your orders",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrdersScreen()),
              ),
            ),
            const Divider(),
            _buildOption(
              context,
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "FAQs & Contact",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              ),
            ),
            const Divider(),
            _buildOption(
              context,
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "Read our policy",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER: Build ListTile Option =================
  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }
}
