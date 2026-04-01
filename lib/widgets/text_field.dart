import 'package:flutter/material.dart';


class AppTextField extends StatelessWidget {
  final TextEditingController? controller; // Controller to read/write the text value
  final String hintText;
  final bool obscureText;
  final String? label;
  final Widget? prefixIcon;  // icon on the left side (like a search icon)

  // Called whenever the text changes
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.label,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Roboto',
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.orangeAccent),
            ),
          ),
        ),
      ],
    );
  }
}