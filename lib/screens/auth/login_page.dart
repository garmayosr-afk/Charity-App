import 'package:charity_app/screens/orphanage/orphanage_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Donator/donator_page.dart';
import 'signup_page.dart';
import '../../widgets/background.dart';
import '../../widgets/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<bool> login(BuildContext context, String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    //return true because login succeeded!
    return true;
  } on FirebaseAuthException catch (e) {
    String errorMessage = "An error occurred. Please try again.";
    if (e.code == 'user-not-found') {
      errorMessage = "No account found with this email.";
    } else if (e.code == 'wrong-password') {
      errorMessage = "Incorrect password. Please try again.";
    } else if (e.code == 'invalid-credential') {
      errorMessage = "Incorrect email or password.";
    } else if (e.code == 'invalid-email') {
      errorMessage = "The email address is badly formatted.";
    } else {
      errorMessage = e.message ?? errorMessage;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    //added return false to tell the button to STOP
    return false;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    //added return false to tell the button to STOP
    return false;
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
  // Add the role variable here too
  final String userRole;

  const LoginPage({super.key, required this.userRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController
        .dispose(); //Clean up controllers when the page is disposed (prevents memory leaks)
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome Back"), centerTitle: true),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                  widget.userRole== 'orphanage' ? "Orphanage Login" : "Donor Login",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final user = await signInWithGoogle();
                        if (user != null && mounted) {
                          debugPrint("Signed in: ${user.user?.displayName}");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DonatorPage(),
                            ),
                          );
                        }
                      },
                      icon: Image.asset('images/google.png', height: 24),
                      label: const Text("Sign in with Google"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
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
                      onPressed: () async {
                        // 1. Force Firebase to forget any old successful logins on this device
                        await FirebaseAuth.instance.signOut();

                        // 2. Run your updated login function and save the answer (true or false)
                        bool success = await login(
                          context,
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        // 3. The Lock: ONLY run the rest of the code if success is EXACTLY true
                        if (success == true &&
                            mounted &&
                            FirebaseAuth.instance.currentUser != null) {
                          String uid = FirebaseAuth.instance.currentUser!.uid;

                          try {
                            DocumentSnapshot userDoc = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(uid)
                                .get();

                            if (userDoc.exists && mounted) {
                              String fetchedRole = userDoc.get('userRole');

                              if (fetchedRole == 'donor') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DonatorPage(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OrphanagePage(),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint("Database Error: $e");
                          }
                        }
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 18),
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
                              builder: (context) =>
                                  SignupPage(userRole: widget.userRole),
                            ),
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
