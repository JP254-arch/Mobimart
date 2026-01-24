// lib/features/auth/screens/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/root_screens_screen.dart';
import 'package:mobimart_app/features/auth/screens/login_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ======== LOADING STATE ========
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ======== USER NOT LOGGED IN ========
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        final userProvider = Provider.of<UserProvider>(context, listen: false);

        return FutureBuilder<void>(
          // Fetch current user data
          future: userProvider.fetchUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final appUser = userProvider.currentUser;

            if (appUser == null) {
              // If something went wrong fetching user data, force logout
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            // ======== NAVIGATE TO ROOT ========
            // Everyone logs in to homepage; role-specific dashboard is in Account tab
            return const RootScreen();
          },
        );
      },
    );
  }
}
