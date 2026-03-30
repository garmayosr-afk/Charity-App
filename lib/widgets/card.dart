// HOW TO USE:
//   RoleCard(
//     icon: Icons.person,
//     color: Colors.blue,
//     title: "I Want To Donate",
//     description: "Support orphanages by...",
//     buttonText: "Continue as Donator",
//     onPressed: () { ... },
//   )

import 'package:flutter/material.dart';
import 'button.dart';

class RoleCard extends StatelessWidget {
  final IconData icon;       // The icon shown in the circle
  final Color color;         // Color for the icon circle, title, and button
  final String title;        // Card title
  final String description;  // Card description text
  final String buttonText;   // Text on the button
  final VoidCallback onPressed; // What happens when the button is tapped

  const RoleCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 15),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: color,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 15),

          AppButton(
            text: buttonText,
            backgroundColor: color,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
