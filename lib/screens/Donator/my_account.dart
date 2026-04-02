import 'package:flutter/material.dart';
import '../../widgets/background.dart';

class MyaccountPage extends StatelessWidget {
  const MyaccountPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Text("My Account"),
        ),
      ),
    );
  }
}