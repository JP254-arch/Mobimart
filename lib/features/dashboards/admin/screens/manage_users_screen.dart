// lib/features/admin/screens/manage_users_screen.dart

import 'package:flutter/material.dart';
import 'user_form_screen.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  static const String routeName = '/admin/manage-users';

  // Mock user data
  final List<Map<String, String>> mockUsers = const [
    {
      "name": "John Doe",
      "email": "johndoe@example.com",
      "phone": "+254700000000",
    },
    {
      "name": "Jane Smith",
      "email": "janesmith@example.com",
      "phone": "+254711111111",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockUsers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = mockUsers[index];
          return Card(
            child: ListTile(
              title: Text(user['name']!),
              subtitle: Text("${user['email']} \n${user['phone']}"),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserFormScreen(user: user),
                    ),
                  );
                },
                child: const Text("Edit"),
              ),
            ),
          );
        },
      ),
    );
  }
}
