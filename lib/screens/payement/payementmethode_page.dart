import 'package:flutter/material.dart';
import '../../widgets/background.dart';
import '../../widgets/card.dart';
import 'payment_page.dart';



class PayementMethodPage extends StatelessWidget {
  const PayementMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Method"),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  RoleCard(
                    icon: Icons.card_giftcard,
                    color: Colors.green,
                    buttonText: "Postal Card",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const PaymentPage();
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  RoleCard(
                    icon: Icons.wallet,
                    color: Colors.lightGreen,
                    buttonText: "Bank Card",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const PaymentPage();
                        }),
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
