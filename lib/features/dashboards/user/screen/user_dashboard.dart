// lib/features/dashboard/screens/user_dashboard.dart

import 'package:flutter/material.dart';
import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/screens/cart_screen.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  static const String routeName = '/user-dashboard';

  // Mock user data
  final String userName = "John Doe";
  final String userEmail = "johndoe@example.com";
  final String userPhone = "+254700000000";

  // Mock stats data
  final int totalOrders = 12;
  final int pendingOrders = 3;
  final double totalSpent = 24500.0;
  final int wishlistCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= USER PROFILE =================
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(userEmail, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(userPhone, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, SettingsScreen.routeName);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= Stats Cards =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Orders',
                  value: totalOrders.toString(),
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  title: 'Pending',
                  value: pendingOrders.toString(),
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Spent',
                  value: 'KSh ${totalSpent.toStringAsFixed(0)}',
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  title: 'Wishlist',
                  value: wishlistCount.toString(),
                  color: Colors.pink,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= Quick Actions =================
            const Text(
              'Quick Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              children: [
                _buildActionCard(
                  context,
                  title: 'Profile',
                  icon: Icons.person_outline,
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pushNamed(context, SettingsScreen.routeName);
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Orders',
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.pushNamed(context, OrdersScreen.routeName);
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Wishlist',
                  icon: Icons.favorite_border,
                  color: Colors.pinkAccent,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WishlistScreen()));
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Cart',
                  icon: Icons.shopping_cart_outlined,
                  color: Colors.greenAccent,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CartScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= Extra Options =================
            const Text(
              'More Options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context,
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
            const Divider(),
            _buildOptionTile(
              context,
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
            const Divider(),
            _buildOptionTile(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helper: Stats Card =================
  Widget _buildStatCard(BuildContext context,
      {required String title, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helper: Action Card =================
  Widget _buildActionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helper: Extra Option Tile =================
  Widget _buildOptionTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }
}
