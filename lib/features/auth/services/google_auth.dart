// lib/features/auth/services/google_auth.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

/// Google authentication helper
/// Works for Mobile (Android/iOS) and Web (via GIS/FedCM)
class GoogleAuth {
  /// Single instance of GoogleSignIn
  static final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile', 'openid'],
    clientId: kIsWeb
        ? '580060550825-9lf1m8lcopa37mhvomh9nmsqq91k9acc.apps.googleusercontent.com'
        : null, // Mobile uses native config automatically
  );

  /// ================= GOOGLE SIGN-IN =================
  /// Returns a GoogleSignInAccount if successful, null if cancelled/fails
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      if (kIsWeb) {
        // Web: try silent sign-in first
        GoogleSignInAccount? account = await googleSignIn.signInSilently();
        if (account != null) {
          debugPrint('Google Web silent sign-in successful: ${account.email}');
          return account;
        }

        // Interactive sign-in fallback (recommended: via GIS button instead)
        account = await googleSignIn.signIn();
        if (account != null) {
          debugPrint(
            'Google Web interactive sign-in successful: ${account.email}',
          );
        } else {
          debugPrint('Google Web sign-in cancelled by user');
        }
        return account;
      } else {
        // Mobile: Android/iOS
        final account = await googleSignIn.signIn();
        if (account != null) {
          debugPrint('Google mobile sign-in successful: ${account.email}');
        } else {
          debugPrint('Google mobile sign-in cancelled by user');
        }
        return account;
      }
    } catch (e, stack) {
      debugPrint('Google sign-in error: $e');
      debugPrint('$stack');
      return null;
    }
  }

  /// ================= GOOGLE SIGN-OUT =================
  /// Signs out from the current account
  static Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      debugPrint('Google signed out successfully');
    } catch (e, stack) {
      debugPrint('Google sign-out failed: $e');
      debugPrint('$stack');
    }
  }

  /// ================= GOOGLE DISCONNECT =================
  /// Completely revokes access
  static Future<void> disconnect() async {
    try {
      await googleSignIn.disconnect();
      debugPrint('Google account disconnected successfully');
    } catch (e, stack) {
      debugPrint('Google disconnect failed: $e');
      debugPrint('$stack');
    }
  }

  /// ================= LISTENER =================
  /// Useful for debugging account changes
  static void attachAccountListener() {
    googleSignIn.onCurrentUserChanged.listen((account) {
      debugPrint('Google account changed: $account');
    });
  }
}
