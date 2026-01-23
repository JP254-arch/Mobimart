// lib/main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobimart_app/constants/theme_data.dart';
import 'package:mobimart_app/core/theme/theme_provider.dart';
import 'package:mobimart_app/features/auth/screens/login_screen.dart';
import 'package:mobimart_app/features/auth/screens/register_screen.dart';
import 'package:mobimart_app/features/dashboards/admin/screens/admin_dashboard.dart';
import 'package:mobimart_app/features/dashboards/user/screen/user_dashboard.dart';
import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/profile_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import 'package:mobimart_app/root_screens_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobimart_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        // Ensure non-null value for theme
        final isDark = themeProvider.isDarkTheme ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mobimart',
          theme: Styles.themeData(
            isDarkTheme: isDark,
            context: context,
          ),

          // ================= HOME =================
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                return const RootScreen(); // Main app after login
              }

              return const LoginScreen(); // Login if not signed in
            },
          ),

          // ================= ROUTES =================
          routes: {
            RegisterScreen.routeName: (_) => const RegisterScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            SettingsScreen.routeName: (_) => const SettingsScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            HelpSupportScreen.routeName: (_) => const HelpSupportScreen(),
            PrivacyPolicyScreen.routeName: (_) => const PrivacyPolicyScreen(),
            UserDashboard.routeName: (_) => const UserDashboard(),
            AdminDashboard.routeName: (_) => const AdminDashboard(),
          },
        );
      },
    );
  }
}
