import 'package:flutter/material.dart';
import '../../widgets/background.dart';


class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Text("Address Page"),
        ),
      ),
    );
  }
}