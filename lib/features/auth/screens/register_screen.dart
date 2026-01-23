// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobimart_app/constants/validator.dart';
import 'package:mobimart_app/features/models/user_model.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/services/my_app_functions.dart';
import 'package:mobimart_app/widgets/image_picker.dart';
import 'package:mobimart_app/widgets/loadding_manager.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = "/RegisterScreen";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  late final TextEditingController _nameController,
      _emailController,
      _passwordController,
      _repeatPasswordController;

  // Focus Nodes
  late final FocusNode _nameFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _repeatPasswordFocusNode;

  // Image
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _uploadedImageUrl;

  bool isLoading = false;
  bool obscureText = true;
  final _formKey = GlobalKey<FormState>();
  String role = 'user'; // default role

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();

    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _repeatPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repeatPasswordFocusNode.dispose();
    super.dispose();
  }

  /// ================= IMAGE PICKER =================
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        final XFile? image = await picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          _pickedImageBytes = await image.readAsBytes();
          _pickedImageName = image.name;
          setState(() {});
        }
      },
      galleryFCT: () async {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          _pickedImageBytes = await image.readAsBytes();
          _pickedImageName = image.name;
          setState(() {});
        }
      },
      removeFCT: () {
        setState(() {
          _pickedImageBytes = null;
          _pickedImageName = null;
        });
      },
    );
  }

  /// ================= CLOUDINARY UPLOAD =================
  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    const cloudName = 'ddvgqblf6';
    const uploadPreset = 'mobimart';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return data['secure_url'] as String?;
    }
    return null;
  }

  /// ================= REGISTER USER =================
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    if (_pickedImageBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a profile image')));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Create Firebase auth user
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2️⃣ Upload profile image
      _uploadedImageUrl = await uploadImage(
            _pickedImageBytes!,
            _pickedImageName ?? 'profile.jpg',
          ) ??
          '';

      if (_uploadedImageUrl!.isEmpty) {
        throw Exception('Image upload failed');
      }

      // 3️⃣ Create UserModel
      final newUser = UserModel(
        uid: userCred.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: role,
        photoUrl: _uploadedImageUrl!,
        isActive: true,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        wishlist: [],
        cart: [],
      );

      // 4️⃣ Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toFirestore());

      // 5️⃣ Update Provider
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(newUser);
      }

      // 6️⃣ Send email verification
      await userCred.user!.sendEmailVerification();

      // 7️⃣ Show success & navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registered! Please verify your email before logging in.'),
          ),
        );

        Navigator.pushReplacementNamed(context, LoginScreen.routName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: LoadngManager(
          isLoading: isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text("Create Account", style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 20),
                SizedBox(
                  height: size.width * 0.3,
                  width: size.width * 0.3,
                  child: PickImageWidget(
                    pickedImageBytes: _pickedImageBytes,
                    onTap: pickImage,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: MyValidators.displayNamevalidator,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocusNode),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(IconlyLight.message),
                        ),
                        validator: MyValidators.emailValidator,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocusNode),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.next,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(IconlyLight.lock),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => obscureText = !obscureText),
                            icon: Icon(
                              obscureText ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: MyValidators.passwordValidator,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_repeatPasswordFocusNode),
                      ),
                      const SizedBox(height: 16),

                      // Repeat Password
                      TextFormField(
                        controller: _repeatPasswordController,
                        focusNode: _repeatPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: 'Repeat password',
                          prefixIcon: const Icon(IconlyLight.lock),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => obscureText = !obscureText),
                            icon: Icon(
                              obscureText ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) => MyValidators.repeatPasswordValidator(
                          value: value,
                          password: _passwordController.text,
                        ),
                        onFieldSubmitted: (_) => _registerUser(),
                      ),
                      const SizedBox(height: 30),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(IconlyLight.add_user),
                          label: const Text('Sign up'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : _registerUser,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
