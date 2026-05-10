import 'package:charity_app/screens/Donator/donator_page.dart';
import 'package:charity_app/screens/orphanage/orphanage_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/background.dart';
import '../../widgets/text_field.dart';

Future<String?> signUp(
  String name,
  String phoneNumber,
  String email,
  String password,
  String role,
) async {
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'uid': uid,
      'userRole': role,
    });

    if (role == 'orphanage') {
      await FirebaseFirestore.instance.collection('orphanages').doc(uid).set({
        'name': name,
        'orphanage_id': uid,
        'general_funds_raised': 0,
        'unique_donors': [],
      });
    }

    return null;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      return 'An account already exists with this email.';
    } else if (e.code == 'weak-password') {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (e.code == 'invalid-email') {
      return 'The email address is invalid.';
    } else if (e.code == 'operation-not-allowed') {
      return 'Email/password sign-up is not enabled.';
    } else {
      return e.message ?? 'Sign-up failed. Please try again.';
    }
  } catch (e) {
    return 'An unexpected error occurred. Please try again.';
  }
}

class SignupPage extends StatefulWidget {
  final String userRole;

  const SignupPage({super.key, required this.userRole});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _validateInputs() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter your full name.');
      return false;
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(name)) {
      _showSnackBar('Name can only contain letters and spaces.');
      return false;
    }

    if (name.length < 2) {
      _showSnackBar('Name must be at least 2 characters long.');
      return false;
    }

    if (phone.isEmpty) {
      _showSnackBar('Please enter your phone number.');
      return false;
    }

    if (phone.length < 8) {
      _showSnackBar('Phone number should be at least 8 numbers.');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showSnackBar('Please enter a valid email address.');
      return false;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter a password.');
      return false;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters.');
      return false;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      _showSnackBar('Password must contain at least one uppercase letter.');
      return false;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      _showSnackBar('Password must contain at least one number.');
      return false;
    }

    if (confirmPassword.isEmpty) {
      _showSnackBar('Please confirm your password.');
      return false;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match.');
      return false;
    }

    return true;
  }

  Future<void> _handleSignUp() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    final error = await signUp(
      nameController.text.trim(),
      phoneController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      widget.userRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      _showSnackBar(error);
      return;
    }

    _showSnackBar('Account created successfully!', isError: false);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || FirebaseAuth.instance.currentUser == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widget.userRole == 'orphanage'
            ? const OrphanagePage()
            : const DonatorPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  AppTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    label: 'Full Name',
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: phoneController,
                    hintText: 'Phone number',
                    label: 'Phone number',
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: emailController,
                    hintText: 'Email',
                    label: 'Email',
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    label: 'Password',
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    label: 'Confirm Password',
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleSignUp,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
