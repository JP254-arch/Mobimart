// lib/features/admin/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import '../screens/manage_users_screen.dart';
import '../screens/manage_products_screen.dart';
import '../screens/manage_orders_screen.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int userCount = 0;
  int productCount = 0;
  int orderCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      if (mounted) {
        setState(() {
          userCount = usersSnapshot.docs.length;
          productCount = productsSnapshot.docs.length;
          orderCount = ordersSnapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ===================== STATS ===================== */
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(title: 'Users', value: userCount.toString()),
                const SizedBox(width: 12),
                _StatCard(title: 'Products', value: productCount.toString()),
                const SizedBox(width: 12),
                _StatCard(title: 'Orders', value: orderCount.toString()),
              ],
            ),

            const SizedBox(height: 32),
            /* ===================== QUICK ACTIONS ===================== */
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              children: [
                _ActionCard(
                  icon: Icons.people,
                  label: 'Manage Users',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageUsersScreen(),
                      ),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.shopping_bag,
                  label: 'Manage Products',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageProductsScreen(),
                      ),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.receipt_long,
                  label: 'View Orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageOrdersScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            /* ===================== MORE OPTIONS ===================== */
            const Text(
              'More Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0.5,
              child: Column(
                children: [
                  _OptionTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _OptionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _OptionTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== STAT CARD ===================== */
class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== ACTION CARD ===================== */
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/* ===================== OPTION TILE ===================== */
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
