import 'package:charity_app/screens/Donator/donator_page.dart';
import 'package:charity_app/screens/orphanage/orphanage_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/background.dart';
import '../../widgets/text_field.dart';

Future<void> signUp(BuildContext context, String name, String email, String password, String role) async {
  try {
    debugPrint("1. Starting Auth creation...");
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    debugPrint("2. Auth successful! Saving to Firestore...");

    String uid = userCredential.user!.uid;

    // 1. Always create the user document in the 'users' collection
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'uid': uid,
      'userRole': role, 
    });

    // 2. NEW LOGIC: If they are an orphanage, create the orphanage profile too!
    if (role == 'orphanage') {
      await FirebaseFirestore.instance.collection('orphanages').doc(uid).set({
        'name' :name,
        'orphanage_id': uid,
        'general_funds_raised': 0,
        'unique_donors': [], 
      });
      debugPrint("Orphanage profile created successfully!");
    }

    debugPrint("3. Firestore save complete!");
  } on FirebaseAuthException catch (e) {
    debugPrint("Auth Error: ${e.code} - ${e.message}");
    // Good practice: show the error to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Authentication failed")));
    }
  } catch (e) {
    debugPrint("Firestore Error: $e");
  }
}

class SignupPage extends StatefulWidget {
  // We added this variable to hold the role ('donor' or 'orphanage')
  final String userRole; 

  const SignupPage({super.key, required this.userRole}); 

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                    "Create Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Fixed: Removed the duplicate Full Name field
                  AppTextField(
                    controller: nameController,
                    hintText:'Full Name',
                    label: 'Full Name',
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
                      onPressed: () async {
                        // Small check to make sure fields aren't empty
                        if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                          return;
                        }

                        await signUp(
                          context,
                          nameController.text.trim(),
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          widget.userRole, 
                        );

                        if (mounted && FirebaseAuth.instance.currentUser != null) {
                          if (widget.userRole == 'donor') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const DonatorPage()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const OrphanagePage()), 
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
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