// lib/features/auth/services/google_auth.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuth {
  /// Single instance of GoogleSignIn
  static final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    clientId: kIsWeb
        ? '580060550825-9lf1m8lcopa37mhvomh9nmsqq91k9acc.apps.googleusercontent.com' // Web OAuth Client ID
        : null, // Mobile uses native config automatically
  );

  /// Sign in with Google (Web & Mobile)
  /// Returns a GoogleSignInAccount or null if sign-in fails or cancelled
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      if (kIsWeb) {
        // Web: try silent sign-in first, fallback to interactive popup
        final account = await googleSignIn.signInSilently();
        if (account != null) return account;

        return await googleSignIn.signIn();
      } else {
        // Mobile (Android/iOS)
        return await googleSignIn.signIn();
      }
    } catch (e) {
      print('Google sign-in failed: $e');
      return null;
    }
  }

  /// Sign out from Google (Web & Mobile)
  static Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (e) {
      print('Google sign-out failed: $e');
    }
  }

  /// Disconnects the user completely (revokes access)
  static Future<void> disconnect() async {
    try {
      await googleSignIn.disconnect();
    } catch (e) {
      print('Google disconnect failed: $e');
    }
  }
}
