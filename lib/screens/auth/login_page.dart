import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Donator/donator_page.dart';
import 'signup_page.dart';
import '../../widgets/background.dart';
import '../../widgets/text_field.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Attempts login and returns an error message string, or null on success.
Future<String?> login(String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return null; // success
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'No account found with this email.';
    } else if (e.code == 'wrong-password') {
      return 'Incorrect password. Please try again.';
    } else if (e.code == 'invalid-email') {
      return 'The email address is invalid.';
    } else if (e.code == 'user-disabled') {
      return 'This account has been disabled.';
    } else if (e.code == 'too-many-requests') {
      return 'Too many attempts. Please try again later.';
    } else if (e.code == 'invalid-credential') {
      return 'Invalid email or password.';
    } else {
      return e.message ?? 'Authentication failed. Please try again.';
    }
  } catch (e) {
    return 'An unexpected error occurred. Please try again.';
  }
}

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    debugPrint("Error: $e");
    return null;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      _showSnackBar('Please enter your email and password.');
      return false;
    }

    if (email.isEmpty) {
      _showSnackBar('Please enter your email address.');
      return false;
    }

    // Basic email format check
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Please enter a valid email address.');
      return false;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter your password.');
      return false;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters.');
      return false;
    }

    return true;
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    final error = await login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error != null) {
      _showSnackBar(error);
      return;
    }

    if (mounted && FirebaseAuth.instance.currentUser != null) {
      _showSnackBar('Login successful!', isError: false);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DonatorPage()),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final user = await signInWithGoogle();

    setState(() => _isLoading = false);

    if (user != null && mounted) {
      _showSnackBar('Signed in as ${user.user?.displayName ?? "user"}!',
          isError: false);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DonatorPage()),
        );
      }
    } else if (mounted) {
      _showSnackBar('Google sign-in was cancelled or failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome Back"),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Donator Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: Image.asset(
                        'images/google.png',
                        height: 24,
                      ),
                      label: const Text("Sign in with Google"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          color: Colors.orangeAccent,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.orangeAccent,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    label: 'Email',
                  ),

                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    label: 'Password',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
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
                              "Login",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Sign up"),
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
