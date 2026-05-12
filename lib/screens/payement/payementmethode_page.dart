import 'package:flutter/material.dart';
import '../../widgets/background.dart';
import '../../widgets/card.dart';
import 'payment_page.dart';

class PayementMethodPage extends StatelessWidget {
  // 1. We added all the variables we need to catch from the InformationsPage
  final double amount; 
  final String? orphanageId;
  final String? campaignId;
  final String donorName;
  final String donorCompany;
  final String donorPhone;
  final String donorEmail;

  const PayementMethodPage({
    super.key, 
    required this.amount,
    this.orphanageId,
    this.campaignId,
    required this.donorName,
    required this.donorCompany,
    required this.donorPhone,
    required this.donorEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Helps your Background widget look seamless
      appBar: AppBar(
        title: const Text(
          "Payment Method", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ), 
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Postal Card Option
                  RoleCard(
                    description: "Pay with a postal card",
                    title: 'Postal Card',
                    icon: Icons.card_giftcard,
                    color: Colors.green,
                    buttonText: "Continue",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PaymentPage(
                              paymentMethod: "postal",
                              // 2. We pass the data securely to the PaymentPage
                              amount: amount,
                              orphanageId: orphanageId,
                              campaignId: campaignId,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bank Card Option
                  RoleCard(
                    description: "Pay with a bank card",
                    title: "Bank Card",
                    icon: Icons.wallet,
                    color: Colors.lightGreen,
                    buttonText: "Continue",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PaymentPage(
                              paymentMethod: "bank_card", // Used "bank_card" as it's standard for Konnect
                              amount: amount,
                              orphanageId: orphanageId,
                              campaignId: campaignId,
                            );
                          },
                        ),
                      );
                    },
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