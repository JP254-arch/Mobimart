// lib/features/auth/screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:mobimart_app/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:mobimart_app/constants/validator.dart';
import 'package:mobimart_app/features/auth/screens/register_screen.dart';
import 'package:mobimart_app/features/auth/screens/forgot_password_screen.dart';
import 'package:mobimart_app/widgets/loadding_manager.dart';
import 'package:mobimart_app/widgets/subtitle_text.dart';
import 'package:mobimart_app/widgets/title_text.dart';
import 'package:mobimart_app/features/auth/widgets/google_button.dart';
import 'package:mobimart_app/features/auth/services/google_auth.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final error = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (error != null) {
        if (error.contains('email not verified')) {
          _showInfoSnack(
            'Your email is not verified yet. You can still log in, but please verify your email for full access.',
          );
          await authProvider.forceLogin(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          _showErrorSnack(error);
          return;
        }
      }
    } catch (e) {
      _showErrorSnack('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final account = await GoogleAuth.signIn();

      if (account == null) {
        if (mounted) _showErrorSnack('Google sign-in cancelled');
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final error = await authProvider.loginWithGoogle(account: account);

      if (!mounted) return;

      if (error != null) _showErrorSnack(error);
    } catch (e) {
      if (mounted) _showErrorSnack('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showInfoSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: LoadngManager(
          isLoading: _isLoading,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    /// APP IMAGE
                    Center(
                      child: Image.asset(
                        'assets/images/mall.png',
                        width: 550,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 30),
                    const TitlesTextWidget(label: 'Welcome'),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: MyValidators.emailValidator,
                            decoration: const InputDecoration(
                              hintText: 'Email address',
                              prefixIcon: Icon(IconlyLight.message),
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_passwordFocus);
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscureText,
                            textInputAction: TextInputAction.done,
                            validator: MyValidators.passwordValidator,
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              hintText: '***********',
                              prefixIcon: const Icon(IconlyLight.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _openForgotPassword,
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
                              onPressed: _isLoading ? null : _login,
                            ),
                          ),

                          const SizedBox(height: 20),
                          const SubtitleTextWidget(label: 'OR CONNECT USING'),
                          const SizedBox(height: 16),

                          GoogleButton(onPressed: _loginWithGoogle),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SubtitleTextWidget(label: "Don't have an account?"),
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
      ),
    );
  }
}
