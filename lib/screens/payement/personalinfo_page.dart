import 'package:flutter/material.dart';
import '../../widgets/background.dart';
import '../../widgets/text_field.dart';
import 'payementmethode_page.dart';

class InformationsPage extends StatefulWidget {
  final double amount; // Changed to double
  final String? orphanageId;
  final String? campaignId;
  
  const InformationsPage({
    super.key, 
    required this.amount, 
    this.orphanageId, 
    this.campaignId
  });

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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _validateAndProceed() {
    String name = nameController.text.trim();
    String company = companynameController.text.trim();
    String phone = phonenumberController.text.trim();
    String email = emailController.text.trim();

    // 1. Validation: Empty Check
    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      _showError('Please fill in all required fields (Name, Phone, Email).');
      return;
    }

    // 2. Validation: Email Regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address.');
      return; 
    }

    // 3. Validation: Phone Regex (allows optional +, spaces, dashes, 8-15 digits)
    final phoneRegex = RegExp(r'^\+?[\d\s-]{8,15}$');
    if (!phoneRegex.hasMatch(phone)) {
      _showError('Please enter a valid phone number (digits only).');
      return; 
    }

    // 4. Send EVERYTHING to Payment Method Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayementMethodPage(
          amount: widget.amount,
          orphanageId: widget.orphanageId,
          campaignId: widget.campaignId,
          donorName: name,
          donorCompany: company,
          donorPhone: phone,
          donorEmail: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    hintText: 'Full Name *',
                    label: 'Full Name *',
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
                    hintText: 'Phone Number *',
                    label: 'Phone number *',
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: emailController,
                    hintText: 'Email *',
                    label: 'Email *',
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
                      onPressed: _validateAndProceed,
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