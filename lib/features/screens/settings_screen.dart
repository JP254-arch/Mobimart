import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobimart_app/features/providers/theme_provider.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/cart_screen.dart';
import 'package:mobimart_app/features/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String passwordMask = '********';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userProvider = context.read<UserProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? '';
        final userEmail = userData['email'] ?? currentUser.email ?? '';
        final userPhone = userData['phone'] ?? '';
        final userPhotoUrl = userData['photoUrl'] ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= PROFILE IMAGE =================
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: userPhotoUrl.isNotEmpty
                            ? NetworkImage(userPhotoUrl)
                            : const AssetImage(
                                    'assets/images/user_placeholder.png')
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            final messenger =
                                ScaffoldMessenger.of(context);
                            final error =
                                await userProvider.uploadProfilePhoto();
                            if (!mounted) return;
                            if (error != null) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.primary,
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ================= THEME SWITCH =================
                Card(
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Use dark appearance'),
                        value: themeProvider.isDarkTheme ?? false,
                        activeColor: colorScheme.primary,
                        onChanged: themeProvider.setDarkTheme,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ================= ACCOUNT INFO =================
                _sectionTitle('Account Information', textTheme),

                Card(
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _editableTile(
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: userName,
                        onSave: (val) async {
                          if (val.isEmpty) return;
                          await userProvider.updateField('name', val);
                        },
                      ),
                      const Divider(height: 1),
                      _editableTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: userEmail,
                        onSave: (val) async {
                          if (val.isEmpty) return;
                          await userProvider.updateField('email', val);
                        },
                      ),
                      const Divider(height: 1),
                      _editableTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: userPhone,
                        onSave: (val) async {
                          await userProvider.updateField('phone', val);
                        },
                      ),
                      const Divider(height: 1),
                      _passwordTile(userProvider),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ================= QUICK NAVIGATION =================
                _sectionTitle('Quick Navigation', textTheme),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.8,
                  children: [
                    _ActionCard(
                      icon: Icons.favorite_border,
                      label: 'Wishlist',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WishlistScreen(),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Cart',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title, TextTheme textTheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ================= EDITABLE TILE =================
  Widget _editableTile({
    required IconData icon,
    required String label,
    required String value,
    required Future<void> Function(String) onSave,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(label),
      subtitle: Text(
        value.isEmpty ? 'Not set' : value,
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
      trailing: Icon(Icons.edit, color: scheme.onSurfaceVariant),
      onTap: () async {
        final newValue = await _inputDialog(
          title: 'Update $label',
          initialValue: value,
        );
        if (newValue == null) return;
        await onSave(newValue);
      },
    );
  }

  // ================= PASSWORD TILE =================
  Widget _passwordTile(UserProvider provider) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.lock_outline, color: scheme.primary),
      title: const Text('Password'),
      subtitle: Text(
        passwordMask,
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
      trailing: Icon(Icons.edit, color: scheme.onSurfaceVariant),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);

        final currentPassword = await _inputDialog(
          title: 'Current Password',
          obscure: true,
        );
        if (currentPassword == null) return;

        final newPassword = await _inputDialog(
          title: 'New Password',
          obscure: true,
        );
        if (newPassword == null) return;

        final error = await provider.updatePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );

        if (!mounted) return;
        if (error != null) {
          messenger.showSnackBar(SnackBar(content: Text(error)));
        }
      },
    );
  }

  // ================= INPUT DIALOG =================
  Future<String?> _inputDialog({
    required String title,
    String initialValue = '',
    bool obscure = false,
  }) {
    final controller = TextEditingController(text: initialValue);
    final scheme = Theme.of(context).colorScheme;

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        backgroundColor: scheme.surface,
        content: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/* ===================== ACTION CARD ===================== */
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}