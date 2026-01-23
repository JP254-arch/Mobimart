// lib/features/admin/screens/user_form_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({
    super.key,
    this.user,
  });

  static const String routeName = '/admin/user-form';

  /// If null → Create user
  /// If not null → Edit user
  final Map<String, dynamic>? user;

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.user?['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.user?['email'] ?? '');
    _phoneController =
        TextEditingController(text: widget.user?['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final userData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    try {
      if (isEditMode) {
        // Update existing user
        final userId = widget.user!['id'];
        await usersCollection.doc(userId).update(userData);

        if (!mounted) return; // <-- Safeguard context after async
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User updated successfully")),
        );
      } else {
        // Create new user
        await usersCollection.add(userData);

        if (!mounted) return; // <-- Safeguard context after async
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User created successfully")),
        );
      }

      if (!mounted) return; // <-- Safeguard context before navigation
      Navigator.pop(context, userData);
    } catch (e) {
      if (!mounted) return; // <-- Safeguard context for error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save user: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit User' : 'Add User'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /* Name */
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
              ),
              const SizedBox(height: 16),

              /* Email */
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              /* Phone */
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Phone number is required'
                        : null,
              ),
              const SizedBox(height: 32),

              /* Submit Button */
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(isEditMode ? 'Save Changes' : 'Create User'),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
