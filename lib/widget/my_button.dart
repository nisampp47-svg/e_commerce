import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyButton({super.key,
    required this.text,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const  EdgeInsets.all(25),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
            colors: [
            Color(0xFF4FACFE),
        Color(0xFF7B5CFF),
        ],
      ),
        ),
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}