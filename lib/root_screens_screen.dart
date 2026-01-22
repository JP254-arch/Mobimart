import 'package:flutter/material.dart';
import 'package:mobimart_app/features/dashboards/user/screen/user_dashboard.dart';
// import 'package:mobimart_app/features/dashboards/admin/screens/admin_dashboard.dart';
import 'package:mobimart_app/features/dashboards/admin/screens/admin_dashboard.dart';
import 'package:mobimart_app/features/screens/profile_screen.dart';
import 'package:mobimart_app/features/screens/cart_screen.dart';
import 'package:mobimart_app/features/screens/home_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import 'package:iconly/iconly.dart';

class RootScreen extends StatefulWidget {
  static const routeName = "/root";

  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int currentScreen = 0;
  late final List<Widget> screens;
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    screens = const [
      HomeScreen(),
      WishlistScreen(),
      CartScreen(),
      ProfileScreen(),
      UserDashboard(),
      AdminDashboard(),


    ];
    controller = PageController(initialPage: currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onDestinationSelected: (index) {
          setState(() => currentScreen = index);
          controller.jumpToPage(currentScreen);
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.activity),
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
            selectedIcon: Icon(IconlyBold.setting),
            icon: Icon(IconlyLight.setting),
            label: "Dashboard",
          ),
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.profile),
            icon: Icon(IconlyLight.profile),
            label: "Admin",
          ),
          

        ],
      ),
    );
  }
}

class AccountScreen {
  const AccountScreen();
}
