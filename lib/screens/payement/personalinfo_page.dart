import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/background.dart';
import '../../widgets/text_field.dart';
import 'payementmethode_page.dart';

Future<String> savePaymentDetails(
    String name, String companyName, String phoneNumber, String email, int amount, String? orphanageId) async {
  final user = FirebaseAuth.instance.currentUser;

  final docRef = await FirebaseFirestore.instance.collection('payements').add({
    'uid': user?.uid,
    'name': name,
    'company_name': companyName,
    'email': email,
    'phone_number': phoneNumber,
    'amount': amount,
    'orphanage_id': orphanageId ?? '',
    'status': 'pending',
    'timestamp': FieldValue.serverTimestamp(),
  });

  return docRef.id;
}

class InformationsPage extends StatefulWidget {
  final int amount;
  final String? orphanageId;

  const InformationsPage({super.key, required this.amount, this.orphanageId});

  @override
  State<InformationsPage> createState() => _InformationsPageState();
}

class _InformationsPageState extends State<InformationsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController companynameController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    companynameController.dispose();
    phonenumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final paymentId = await savePaymentDetails(
        nameController.text.trim(),
        companynameController.text.trim(),
        phonenumberController.text.trim(),
        emailController.text.trim(),
        widget.amount,
        widget.orphanageId,
      );

      if (mounted && FirebaseAuth.instance.currentUser != null) {
        // Split name into first and last
        final nameParts = nameController.text.trim().split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PayementMethodPage(
              amount: widget.amount,
              firstName: firstName,
              lastName: lastName,
              email: emailController.text.trim(),
              phoneNumber: phonenumberController.text.trim(),
              paymentId: paymentId,
              orphanageId: widget.orphanageId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.trim().length < 8) {
                          return 'Phone number must be at least 8 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    AppTextField(
                      controller: emailController,
                      hintText: 'Email',
                      label: 'Email',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
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
                        onPressed: _isSubmitting ? null : _onContinue,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
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
      ),
    );
  }
}
