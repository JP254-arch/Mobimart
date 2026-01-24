// lib/features/admin/screens/admin_dashboard_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/providers/theme_provider.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/home_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/profile_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import 'package:mobimart_app/features/screens/cart_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import '../screens/manage_users_screen.dart';
import '../screens/manage_products_screen.dart';
import '../screens/manage_orders_screen.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final user = FirebaseAuth.instance.currentUser;

  int userCount = 0;
  int productCount = 0;
  int orderCount = 0;

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
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
    final theme = Provider.of<ThemeProvider>(context);
    final colorScheme = theme.themeData.colorScheme;
    final textTheme = theme.themeData.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: buildAdminDrawer(
        context,
        userName: userName,
        userEmail: userEmail,
        userPhotoUrl: userPhotoUrl,
        colorScheme: colorScheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context, colorScheme, textTheme),
            const SizedBox(height: 24),
            _buildStatsOverview(colorScheme),
            const SizedBox(height: 32),
            _buildQuickActions(colorScheme),
            const SizedBox(height: 32),
            _buildMoreOptions(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                ? NetworkImage(userPhotoUrl!)
                : const AssetImage('assets/images/user_placeholder.png')
                      as ImageProvider,
          ),
          const SizedBox(height: 12),
          Text(
            userName.isNotEmpty ? userName : 'Loading...',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail.isNotEmpty ? userEmail : '-',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 4),
          Text(
            userPhone.isNotEmpty ? userPhone : '-',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.edit),
            label: const Text("Edit Profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
              title: 'Users',
              value: userCount.toString(),
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: 'Products',
              value: productCount.toString(),
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: 'Orders',
              value: orderCount.toString(),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            _ActionCard(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () =>
                  Navigator.pushNamed(context, ProfileScreen.routeName),
              colorScheme: colorScheme,
            ),
            _ActionCard(
              icon: Icons.people,
              label: 'Manage Users',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
              ),
              colorScheme: colorScheme,
            ),
            _ActionCard(
              icon: Icons.shopping_bag,
              label: 'Manage Products',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
              ),
              colorScheme: colorScheme,
            ),
            _ActionCard(
              icon: Icons.receipt_long,
              label: 'View Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
              ),
              colorScheme: colorScheme,
            ),
            _ActionCard(
              icon: Icons.shopping_cart,
              label: 'Cart',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              colorScheme: colorScheme,
            ),
            _ActionCard(
              icon: Icons.favorite_border,
              label: 'Wishlist',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              ),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreOptions(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0.5,
          color: colorScheme.surface,
          child: Column(
            children: [
              _OptionTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
                colorScheme: colorScheme,
              ),
              const Divider(height: 1),
              _OptionTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
                colorScheme: colorScheme,
              ),
              const Divider(height: 1),
              _OptionTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Drawer buildAdminDrawer(
    BuildContext context, {
    required String userName,
    required String userEmail,
    String? userPhotoUrl,
    required ColorScheme colorScheme,
  }) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundImage: (userPhotoUrl != null && userPhotoUrl.isNotEmpty)
                  ? NetworkImage(userPhotoUrl)
                  : const AssetImage('assets/images/user_placeholder.png')
                        as ImageProvider,
            ),
            decoration: BoxDecoration(color: colorScheme.primary),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, HomeScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Manage Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Manage Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Wishlist'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ===================== STAT CARD ===================== */
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.colorScheme,
  });
  final String title;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: colorScheme.surface,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
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
    required this.colorScheme,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        color: colorScheme.surface,
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: colorScheme.onSurface),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
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
    required this.colorScheme,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurface),
      title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurface,
      ),
      onTap: onTap,
    );
  }
}
