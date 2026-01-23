// lib/features/admin/screens/manage_users_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_form_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  static const String routeName = '/admin/manage-users';

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userDocs = snapshot.data?.docs ?? [];

          if (userDocs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: userDocs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = userDocs[index];
              final userData = {
                'id': user.id,
                'name': user['name'] ?? '',
                'email': user['email'] ?? '',
                'phone': user['phone'] ?? '',
              };

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(userData['name']),
                  subtitle: Text('${userData['email']}\n${userData['phone']}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          // Open UserFormScreen in edit mode
                          final updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserFormScreen(user: userData),
                            ),
                          );
                          if (updatedUser != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User updated')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete User'),
                              content: const Text(
                                  'Are you sure you want to delete this user?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await usersCollection.doc(user.id).delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User deleted')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open UserFormScreen in create mode
          final newUser = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
          if (newUser != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User created')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
