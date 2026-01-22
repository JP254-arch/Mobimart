class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'customer',
  });

  // Convert AppUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // Create AppUser from Firestore document
  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
    );
  }
}
