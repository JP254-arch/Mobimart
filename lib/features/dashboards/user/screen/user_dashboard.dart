// lib/features/dashboards/user/screen/user_dashboard.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobimart_app/features/cart/screens/cart_screen.dart';
import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import 'package:mobimart_app/features/screens/profile_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  static const routeName = "/user-dashboard";

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

      if (userDoc.exists && mounted) {
        final data = userDoc.data()!;
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      drawer: _buildSideDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(theme),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildQuickActions(theme),
            const SizedBox(height: 24),
            _buildExtraOptions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName.isNotEmpty ? userName : "Loading..."),
            accountEmail: Text(userEmail.isNotEmpty ? userEmail : "-"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                  ? NetworkImage(userPhotoUrl!)
                  : const AssetImage('assets/images/user_placeholder.png')
                        as ImageProvider,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserDashboard()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Wishlist"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Cart"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                ? NetworkImage(userPhotoUrl!)
                : const AssetImage('assets/images/user_placeholder.png')
                      as ImageProvider,
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
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            userPhone.isNotEmpty ? userPhone : '-',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.edit),
            label: const Text("Edit Profile"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, orderSnapshot) {
        if (!orderSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int totalOrders = 0;
        int pendingOrders = 0;
        double totalSpent = 0;

        final orders = orderSnapshot.data!.docs;
        totalOrders = orders.length;

        for (var doc in orders) {
          final data = doc.data() as Map<String, dynamic>;

          final status = (data['status'] ?? '').toString();

          if (status == 'pending') {
            pendingOrders++;
          }

          /// ✅ Calculate spent money from items
          if (status == 'paid') {
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

            for (var item in items) {
              final price = (item['price'] ?? 0) as num;
              final quantity = (item['quantity'] ?? 1) as num;

              totalSpent += price * quantity;
            }
          }
        }

        /// ✅ Wishlist comes from USERS document (NOT collection)
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            int wishlistCount = 0;

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;

              final wishlist = List.from(userData['wishlist'] ?? []);
              wishlistCount = wishlist.length;
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Orders',
                        value: totalOrders.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
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
                        title: 'Total Spent',
                        value: 'KSh ${totalSpent.toStringAsFixed(0)}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Wishlist',
                        value: wishlistCount.toString(),
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              title: 'Profile',
              icon: Icons.person_outline,
              color: Colors.blueAccent,
              onTap: () =>
                  Navigator.pushNamed(context, ProfileScreen.routeName),
            ),
            _buildActionCard(
              title: 'Orders',
              icon: Icons.shopping_bag_outlined,
              color: Colors.orangeAccent,
              onTap: () => Navigator.pushNamed(context, OrdersScreen.routeName),
            ),
            _buildActionCard(
              title: 'Wishlist',
              icon: Icons.favorite_border,
              color: Colors.pinkAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              ),
            ),
            _buildActionCard(
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
      ],
    );
  }

  Widget _buildExtraOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Options',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        _buildOptionTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
          ),
        ),
        const Divider(),
        _buildOptionTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
        const Divider(),
        _buildOptionTile(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
        ),
      ],
    );
  }

  Widget _buildStatCard({
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

  Widget _buildActionCard({
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

  Widget _buildOptionTile({
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
