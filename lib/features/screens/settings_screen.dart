// lib/features/profile/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:mobimart_app/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  // ✅ Proper route name
  static const String routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock user data
  String userName = "John Doe";
  String userEmail = "johndoe@example.com";
  String userPhone = "+254700000000";
  String password = "********";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.getIsDarkTHeme ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= USER IMAGE =================
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage('assets/images/user_placeholder.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement image picker
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ================= DARK / LIGHT MODE =================
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDark,
              onChanged: (value) {
                themeProvider.setDarkTheme(value);
              },
            ),
            const Divider(),

            // ================= NAME =================
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Name"),
              subtitle: Text(userName),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newName = await _showInputDialog(
                    context,
                    title: "Update Name",
                    initialValue: userName,
                  );
                  if (newName != null && newName.isNotEmpty) {
                    setState(() => userName = newName);
                  }
                },
              ),
            ),
            const Divider(),

            // ================= EMAIL =================
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email"),
              subtitle: Text(userEmail),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newEmail = await _showInputDialog(
                    context,
                    title: "Update Email",
                    initialValue: userEmail,
                  );
                  if (newEmail != null && newEmail.isNotEmpty) {
                    setState(() => userEmail = newEmail);
                  }
                },
              ),
            ),
            const Divider(),

            // ================= PHONE =================
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text("Phone"),
              subtitle: Text(userPhone),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newPhone = await _showInputDialog(
                    context,
                    title: "Update Phone",
                    initialValue: userPhone,
                  );
                  if (newPhone != null && newPhone.isNotEmpty) {
                    setState(() => userPhone = newPhone);
                  }
                },
              ),
            ),
            const Divider(),

            // ================= PASSWORD =================
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text("Password"),
              subtitle: Text(password),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newPassword = await _showInputDialog(
                    context,
                    title: "Update Password",
                    initialValue: "",
                    obscureText: true,
                  );
                  if (newPassword != null && newPassword.isNotEmpty) {
                    setState(() => password = "*" * newPassword.length);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER: Input Dialog =================
  Future<String?> _showInputDialog(
    BuildContext context, {
    required String title,
    String initialValue = "",
    bool obscureText = false,
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
