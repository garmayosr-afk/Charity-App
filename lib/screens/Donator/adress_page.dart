import 'package:flutter/material.dart';
import '../../widgets/background.dart';

class AdressePage extends StatelessWidget {
  const AdressePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Background(
        child: Center(
          child: Text("Address Page"),
        ),
      ),
    );
  }
}
