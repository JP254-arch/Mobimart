import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/providers/theme_provider.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import '../screens/manage_users_screen.dart';
import '../screens/manage_products_screen.dart';
import '../screens/manage_orders_screen.dart';
import 'package:provider/provider.dart';
import '../screens/manage_finance_screen.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.themeData;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
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
            _buildProfileSection(colorScheme, textTheme),
            const SizedBox(height: 28),
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

  Widget _buildProfileSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                ? NetworkImage(userPhotoUrl!)
                : const AssetImage('assets/images/user_placeholder.png')
                      as ImageProvider,
          ),
          const SizedBox(height: 14),
          Text(
            userName.isNotEmpty ? userName : 'Loading...',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
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
              icon: Icons.people,
              containerColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: 'Products',
              value: productCount.toString(),
              icon: Icons.shopping_bag,
              containerColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: 'Orders',
              value: orderCount.toString(),
              icon: Icons.receipt_long,
              containerColor: colorScheme.tertiaryContainer,
              foregroundColor: colorScheme.onTertiaryContainer,
            ),
          ],
        ),
      ],
    );
  }

  // ================== Quick Actions Section ==================
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
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
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
              label: 'Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
              ),
              colorScheme: colorScheme,
            ),
            _ActionCard(
              icon: Icons.monetization_on_outlined,
              label: 'Finance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageFinanceScreen()),
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
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _OptionTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
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
              ),
              const Divider(height: 1),
              _OptionTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
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
            decoration: BoxDecoration(color: colorScheme.primaryContainer),
            accountName: Text(
              userName,
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
            accountEmail: Text(
              userEmail,
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: (userPhotoUrl != null && userPhotoUrl.isNotEmpty)
                  ? NetworkImage(userPhotoUrl)
                  : const AssetImage('assets/images/user_placeholder.png')
                        as ImageProvider,
            ),
          ),
          _drawerItem(Icons.people, 'Manage Users', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
            );
          }),
          _drawerItem(Icons.shopping_bag, 'Manage Products', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
            );
          }),
          _drawerItem(Icons.receipt_long, 'Manage Orders', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
            );
          }),
          const Divider(),
          _drawerItem(Icons.settings_outlined, 'Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

/* ===================== STAT CARD ===================== */
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.containerColor,
    required this.foregroundColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color containerColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: containerColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: foregroundColor.withOpacity(0.8)),
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(icon, color: colorScheme.onPrimaryContainer),
            ),
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
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
