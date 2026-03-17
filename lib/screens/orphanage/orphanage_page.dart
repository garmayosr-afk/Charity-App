import 'package:flutter/material.dart';

class OrphanagePage extends StatelessWidget {
  const OrphanagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF1E9DC),
              Color(0xFFDDE6DB),
            ],
          ),
        ),
      ),
    );
  }
}
