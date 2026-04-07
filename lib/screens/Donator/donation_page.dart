import 'package:charity_app/screens/Donator/adress_page.dart';
import 'package:flutter/material.dart';
import '../../widgets/background.dart';
import '../payement/prepayement_page.dart';
import '../../widgets/card.dart';
import 'adress_page.dart';


class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Now"),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Choose A Campaign To Donate',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFB08060),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  RoleCard(
                    icon: Icons.attach_money,
                    color: Colors.orangeAccent,
                    title: "Money Donation ",
                    description:
                    "Donate Money Directly",
                    buttonText: "Donate Money",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                       builder: (context) => const PrepayementPage(),
                      ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  RoleCard(
                    icon: Icons.checkroom,
                    color: Colors.orangeAccent,
                    title: "Other Donations ",
                    description:
                    "Donate new or gently used clothing, Food And School Materials for children of all ages",
                    buttonText: "Donate now",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const AdressePage(),
                      ));
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}