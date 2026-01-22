import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register a new user
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String role = 'customer',
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? firebaseUser = cred.user;

    if (firebaseUser == null) {
      throw Exception('User registration failed');
    }

    AppUser user = AppUser(
      id: firebaseUser.uid,
      name: name,
      email: email,
      role: role,
    );

    // Save user to Firestore
    await _db.collection('users').doc(firebaseUser.uid).set(user.toMap());

    return user; // non-nullable
  }

  // Login existing user
  Future<AppUser> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? firebaseUser = cred.user;

    if (firebaseUser == null) {
      throw Exception('Login failed');
    }

    // Fetch user data from Firestore
    DocumentSnapshot doc =
        await _db.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  Future<AppUser?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    DocumentSnapshot doc =
        await _db.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
