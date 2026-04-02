import 'package:flutter/material.dart';
import '../../widgets/background.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Text("about us page"),
        ),
      ),
    );
  }
}