import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/background.dart';
import '../../widgets/text_field.dart';
import 'payementmethode_page.dart';

Future<void> savePaymentDetails(
    String name, String companyName, String phoneNumber, String email) async {
  final user = FirebaseAuth.instance.currentUser;

  await FirebaseFirestore.instance.collection('payements').add({
    'uid': user?.uid,
    'name': name,
    'company_name': companyName,
    'email': email,
    'phone_number': phoneNumber,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

class InformationsPage extends StatefulWidget {
  const InformationsPage({super.key});

  @override
  State<InformationsPage> createState() => _InformationsPageState();
}

class _InformationsPageState extends State<InformationsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController companynameController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    companynameController.dispose();
    phonenumberController.dispose();
    emailController.dispose();
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
                    "Personal Information",
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
                    controller: companynameController,
                    hintText: 'Company Name',
                    label: 'Company Name (optional)',
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: phonenumberController,
                    hintText: 'Phone Number',
                    label: 'Phone number',
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: emailController,
                    hintText: 'Email',
                    label: 'Email',
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
                        await savePaymentDetails(
                          nameController.text.trim(),
                          companynameController.text.trim(),
                          phonenumberController.text.trim(),
                          emailController.text.trim(),
                        );
                        if (mounted &&
                            FirebaseAuth.instance.currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PayementMethodPage()),
                          );
                        }
                      },
                      child: const Text(
                        "Continue Payment",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
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
