// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;

      final data = snapshot.data();
      if (data != null) {
        setState(() {
          userName = data['name'] ?? '';
          userEmail = data['email'] ?? currentUser.email ?? '';
          userPhone = data['phone'] ?? '';
          userPhotoUrl = data['photoUrl'];
        });
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= LOGOUT =================

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // DO NOT navigate here
      // AuthGate will redirect automatically
    } catch (e) {
      debugPrint('Logout error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ================= USER INFO =================
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                              ? NetworkImage(userPhotoUrl!)
                              : const AssetImage(
                                      'assets/images/user_placeholder.png',
                                    )
                                    as ImageProvider,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userName.isNotEmpty ? userName : '—',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail.isNotEmpty ? userEmail : '—',
                          style: TextStyle(color: theme.hintColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userPhone.isNotEmpty ? userPhone : '—',
                          style: TextStyle(color: theme.hintColor),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              SettingsScreen.routeName,
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= OPTIONS =================
                  _buildOption(
                    context,
                    icon: Icons.favorite_border,
                    title: 'Wishlist',
                    subtitle: 'View your favorite items',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    ),
                  ),
                  const Divider(),

                  _buildOption(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Orders',
                    subtitle: 'View your orders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrdersScreen()),
                    ),
                  ),
                  const Divider(),

                  _buildOption(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'FAQs & Contact',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    ),
                  ),
                  const Divider(),

                  _buildOption(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our policy',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                  ),
                  const Divider(),

                  _buildOption(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ),
    );
  }

  // ================= HELPER =================

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
