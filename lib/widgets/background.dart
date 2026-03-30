import 'package:flutter/material.dart';


class Background extends StatelessWidget {
  final Widget child;

  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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

      // Show the child widget on top of the gradient
      child: child,
    );
  }
}