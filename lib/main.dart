import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobimart_app/features/auth/providers/auth_provider.dart';
import 'package:mobimart_app/features/providers/theme_provider.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
// import 'package:mobimart_app/features/providers/payment_provider.dart';
import 'package:mobimart_app/features/products/providers/product_provider.dart';
import 'package:mobimart_app/auth_gate.dart';
import 'package:mobimart_app/features/auth/screens/login_screen.dart';
import 'package:mobimart_app/features/auth/screens/register_screen.dart';
import 'package:mobimart_app/features/screens/help_support_screen.dart';
import 'package:mobimart_app/features/screens/privacy_policy_screen.dart';
import 'package:mobimart_app/features/screens/profile_screen.dart';
import 'package:mobimart_app/features/screens/settings_screen.dart';
import 'package:mobimart_app/features/orders/screens/order_screen.dart';
import 'package:mobimart_app/features/dashboards/user/screen/user_dashboard.dart';
import 'package:mobimart_app/features/dashboards/admin/screens/admin_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:mobimart_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()), 
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mobimart',
          theme: themeProvider.themeData,
          home: const AuthGate(),
          routes: {
            LoginScreen.routeName: (_) => const LoginScreen(),
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
