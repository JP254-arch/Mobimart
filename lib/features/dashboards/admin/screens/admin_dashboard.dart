import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
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
              children: const [
                _StatCard(title: 'Users', value: '128'),
                SizedBox(width: 12),
                _StatCard(title: 'Products', value: '56'),
                SizedBox(width: 12),
                _StatCard(title: 'Orders', value: '214'),
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
                    // Navigator.pushNamed(context, ManageUsersScreen.routeName);
                  },
                ),
                _ActionCard(
                  icon: Icons.shopping_bag,
                  label: 'Manage Products',
                  onTap: () {
                    // Navigator.pushNamed(context, ManageProductsScreen.routeName);
                  },
                ),
                _ActionCard(
                  icon: Icons.receipt_long,
                  label: 'View Orders',
                  onTap: () {
                    // Navigator.pushNamed(context, ManageOrdersScreen.routeName);
                  },
                ),
                _ActionCard(
                  icon: Icons.analytics,
                  label: 'Reports',
                  onTap: () {
                    // Navigator.pushNamed(context, ReportsScreen.routeName);
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
                      // Navigator.pushNamed(context, HelpScreen.routeName);
                    },
                  ),
                  const Divider(height: 1),
                  _OptionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      // Navigator.pushNamed(context, PrivacyPolicyScreen.routeName);
                    },
                  ),
                  const Divider(height: 1),
                  _OptionTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      // Navigator.pushNamed(context, SettingsScreen.routeName);
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
  const _StatCard({
    required this.title,
    required this.value,
  });

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
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
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
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
