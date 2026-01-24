// lib/root_screen.dart

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'features/providers/user_provider.dart';
import 'features/screens/home_screen.dart';
import 'features/screens/wishlist_screen.dart';
import 'features/screens/cart_screen.dart';
import 'features/screens/profile_screen.dart';
import 'features/dashboards/user/screen/user_dashboard.dart';
import 'features/dashboards/admin/screens/admin_dashboard.dart';

class RootScreen extends StatefulWidget {
  static const routeName = "/root";

  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int currentScreen = 0;
  late PageController controller;
  late List<Widget> screens;
  late List<NavigationDestination> destinations;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: currentScreen);
    _initScreensAndDestinations();
  }

  void _initScreensAndDestinations() {
    screens = [
      const HomeScreen(),
      const WishlistScreen(),
      const CartScreen(),
      const ProfileScreen(),
      const AccountScreen(),
    ];

    destinations = const [
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.home),
        icon: Icon(IconlyLight.home),
        label: "Home",
      ),
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.heart),
        icon: Icon(IconlyLight.heart),
        label: "Wishlist",
      ),
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.bag_2),
        icon: Icon(IconlyLight.bag_2),
        label: "Cart",
      ),
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.profile),
        icon: Icon(IconlyLight.profile),
        label: "Profile",
      ),
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.activity),
        icon: Icon(IconlyLight.activity),
        label: "Account",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onDestinationSelected: (index) {
          setState(() => currentScreen = index);
          controller.jumpToPage(currentScreen);
        },
        destinations: destinations,
      ),
    );
  }
}

/// ================= ACCOUNT SCREEN =================
/// Shows the correct dashboard based on role
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.currentUser == null) {
      return const Center(child: Text("No user logged in"));
    }

    // Returns admin or user dashboard
    return userProvider.isAdmin
        ? const AdminDashboard()
        : const UserDashboard();
  }
}
