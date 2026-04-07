import 'package:flutter/material.dart';
import '../../widgets/background.dart';

class AdressePage extends StatelessWidget {
  const AdressePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Text("You Can Donate To The Following Adresses"),
      ),
    );
  }
}
