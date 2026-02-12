// lib/features/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:mobimart_app/features/cart/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/profile_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // Helper to safely get profile image
    ImageProvider<Object> getProfileImage() {
      if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
        return NetworkImage(user.photoUrl!);
      } else {
        return const AssetImage('assets/images/user_placeholder.png');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Guest'),
              accountEmail: Text(user?.email ?? '-'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: getProfileImage(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                if (user != null) {
                  Navigator.pushNamed(context, ProfileScreen.routeName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login first')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                if (user != null) {
                  Navigator.pushNamed(context, CartScreen.routeName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login first')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Wishlist'),
              onTap: () {
                Navigator.pop(context);
                if (user != null) {
                  Navigator.pushNamed(context, WishlistScreen.routeName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login first')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: getProfileImage(),
            ),
            const SizedBox(height: 16),
            Text(
              'Hello, ${user?.name ?? 'Guest'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '-',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
