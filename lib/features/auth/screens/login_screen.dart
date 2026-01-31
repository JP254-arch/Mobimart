// lib/features/auth/screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:mobimart_app/constants/validator.dart';
import 'package:mobimart_app/features/auth/screens/register_screen.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/widgets/loadding_manager.dart';
import 'package:mobimart_app/widgets/subtitle_text.dart';
import 'package:mobimart_app/widgets/title_text.dart';
import 'package:mobimart_app/features/auth/widgets/google_button.dart';
import 'package:mobimart_app/features/auth/services/google_auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final errorMessage = await userProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      // AuthGate will automatically redirect if login succeeds
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Use GoogleAuth wrapper for Web & Mobile
      final account = await GoogleAuth.signIn();
      if (account == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in aborted')),
          );
        }
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final errorMessage = await userProvider.loginWithGoogle(account: account);

      if (errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      // AuthGate will handle redirection
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: LoadngManager(
          isLoading: _isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Mobimart',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: TitlesTextWidget(label: 'Welcome back!'),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: Icon(IconlyLight.message),
                          ),
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                          validator: MyValidators.emailValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: '***********',
                            prefixIcon: const Icon(IconlyLight.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                            ),
                          ),
                          onFieldSubmitted: (_) => _login(),
                          validator: MyValidators.passwordValidator,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Add forgot password logic
                            },
                            child: const SubtitleTextWidget(
                              label: 'Forgot password?',
                              fontStyle: FontStyle.italic,
                              textDecoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            label: const Text('Login'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _login,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SubtitleTextWidget(label: 'OR CONNECT USING'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GoogleButton(
                                onPressed: _loginWithGoogle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SubtitleTextWidget(
                              label: "Don't have an account?",
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  RegisterScreen.routeName,
                                );
                              },
                              child: const SubtitleTextWidget(
                                label: 'Create One?',
                                fontStyle: FontStyle.italic,
                                textDecoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
