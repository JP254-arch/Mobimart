// ignore_for_file: use_build_context_synchronously, duplicate_ignore, non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobimart_app/constants/validator.dart';
import 'package:mobimart_app/features/auth/screens/login_screen.dart';
import 'package:mobimart_app/features/models/user_model.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/services/my_app_functions.dart';
import 'package:mobimart_app/widgets/image_picker.dart';
import 'package:mobimart_app/widgets/loadding_manager.dart';
import 'package:mobimart_app/widgets/subtitle_text.dart';
import 'package:mobimart_app/widgets/title_text.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const routName = "/RegisterScreen";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  bool obscureText = true;
  late final TextEditingController _nameController,
      _emailController,
      _passwordController,
      _repeatPasswordController;

  late final FocusNode _nameFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _repeatPasswordFocusNode;

  String role = 'user';
  bool isLoading = false;
  late String userImageUrl;

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    // Focus Nodes
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _repeatPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _nameController.dispose();
      _emailController.dispose();
      _passwordController.dispose();
      _repeatPasswordController.dispose();
      // Focus Nodes
      _nameFocusNode.dispose();
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
      _repeatPasswordFocusNode.dispose();
    }
    super.dispose();
  }

  Future<void> LocalImagePicker() async {
    final ImagePicker imagePicker = ImagePicker();

    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        final XFile? image = await imagePicker.pickImage(
          source: ImageSource.camera,
        );

        if (image != null) {
          _pickedImageBytes = await image.readAsBytes();
          _pickedImageName = image.name;
          setState(() {});
        }
      },
      galleryFCT: () async {
        final XFile? image = await imagePicker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          _pickedImageBytes = await image.readAsBytes();
          _pickedImageName = image.name;
          setState(() {});
        }
      },
      removeFCT: () async {
        setState(() {
          _pickedImageBytes = null;
          _pickedImageName = null;
        });
      },
    );
  }

  Future<String?> uploadImageToCloudinary(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final cloudName = 'ddvgqblf6';
    final uploadPreset = 'mobimart';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return data['secure_url'];
    }
    return null;
  }

  Future<void> _registerFCT() async {
    _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_pickedImageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Upload to Cloudinary
      userImageUrl = userImageUrl =
          await uploadImageToCloudinary(
            _pickedImageBytes!,
            _pickedImageName ?? 'profile.jpg',
          ) ??
          '';

      if (userImageUrl.isEmpty) {
        throw Exception('Image upload failed');
      }

      final newUser = UserModel(
        uid: userCredentials.user!.uid,
        email: _emailController.text.trim(),
        role: role,
        username: _nameController.text.trim(),
        userCart: [],
        userWish: [],
        userImage: userImageUrl,
        createdAt: Timestamp.now(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(newUser);
      }

      await userCredentials.user!.sendEmailVerification();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registered! Please verify your email before logging in.',
          ),
        ),
      );

      Navigator.pushReplacementNamed(context, LoginScreen.routName);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: LoadngManager(
          isLoading: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // const BackButton(),
                  const SizedBox(height: 60),
                  Text(
                    "Create Account",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlesTextWidget(label: "Welcome back!"),
                        SubtitleTextWidget(label: "Your welcome message"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: size.width * 0.3,
                    width: size.width * 0.3,
                    child: PickImageWidget(
                      pickedImageBytes: _pickedImageBytes,
                      onTap: () async {
                        await LocalImagePicker();
                      },
                    ),
                  ),

                  Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            hintText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_emailFocusNode);
                          },
                          validator: (value) {
                            return MyValidators.displayNamevalidator(value);
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email address",
                            prefixIcon: Icon(IconlyLight.message),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_passwordFocusNode);
                          },
                          validator: (value) {
                            return MyValidators.emailValidator(value);
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "***********",
                            prefixIcon: const Icon(IconlyLight.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            FocusScope.of(
                              context,
                            ).requestFocus(_repeatPasswordFocusNode);
                          },
                          validator: (value) {
                            return MyValidators.passwordValidator(value);
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _repeatPasswordController,
                          focusNode: _repeatPasswordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "Repeat password",
                            prefixIcon: const Icon(IconlyLight.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            await _registerFCT();
                          },
                          validator: (value) {
                            return MyValidators.repeatPasswordValidator(
                              value: value,
                              password: _passwordController.text,
                            );
                          },
                        ),
                        const SizedBox(height: 36.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(IconlyLight.add_user),
                            label: const Text("Sign up"),
                            onPressed: isLoading
                                ? null // disable button while loading
                                : () async {
                                    await _registerFCT();
                                  },
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
      ),
    );
  }
}
