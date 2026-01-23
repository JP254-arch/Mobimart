// lib/features/dashboard/screens/user_dashboard.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/screens/cart_screen.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  static const String routeName = '/user-dashboard';

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final user = FirebaseAuth.instance.currentUser;

  int totalOrders = 0;
  int pendingOrders = 0;
  double totalSpent = 0.0;
  int wishlistCount = 0;

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchStats();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        if (!mounted) return;
        setState(() {
          userName = data['name'] ?? '';
          userEmail = data['email'] ?? user!.email ?? '';
          userPhone = data['phone'] ?? '';
          userPhotoUrl = data['photoUrl'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _fetchStats() async {
    if (user == null) return;

    try {
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user!.uid)
          .get();

      final wishlistSnapshot = await FirebaseFirestore.instance
          .collection('wishlist')
          .where('userId', isEqualTo: user!.uid)
          .get();

      int pending = 0;
      double spent = 0.0;

      for (var order in ordersSnapshot.docs) {
        final orderData = order.data();
        if (orderData['status'] == 'pending') pending++;
        spent += (orderData['total'] ?? 0).toDouble();
      }

      if (!mounted) return;
      setState(() {
        totalOrders = ordersSnapshot.docs.length;
        pendingOrders = pending;
        totalSpent = spent;
        wishlistCount = wishlistSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

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
                    backgroundImage: (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                        ? NetworkImage(userPhotoUrl!)
                        : const AssetImage('assets/images/user_placeholder.png') as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName.isNotEmpty ? userName : 'Loading...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail.isNotEmpty ? userEmail : '-',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userPhone.isNotEmpty ? userPhone : '-',
                    style: const TextStyle(color: Colors.grey),
                  ),
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
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Orders',
                    value: totalOrders.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Pending',
                    value: pendingOrders.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Spent',
                    value: 'KSh ${totalSpent.toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Wishlist',
                    value: wishlistCount.toString(),
                    color: Colors.pink,
                  ),
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
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(
                  context,
                  title: 'Profile',
                  icon: Icons.person_outline,
                  color: Colors.blueAccent,
                  onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                ),
                _buildActionCard(
                  context,
                  title: 'Orders',
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.orangeAccent,
                  onTap: () => Navigator.pushNamed(context, OrdersScreen.routeName),
                ),
                _buildActionCard(
                  context,
                  title: 'Wishlist',
                  icon: Icons.favorite_border,
                  color: Colors.pinkAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: 'Cart',
                  icon: Icons.shopping_cart_outlined,
                  color: Colors.greenAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              ),
            ),
            const Divider(),
            _buildOptionTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            const Divider(),
            _buildOptionTile(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helper: Stats Card =================
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
    );
  }

  // ================= Helper: Action Card =================
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helper: Extra Option Tile =================
  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }
}
