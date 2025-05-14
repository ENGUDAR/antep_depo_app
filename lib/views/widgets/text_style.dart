import 'package:antep_depo_app/constants/project_colors.dart';
import 'package:flutter/material.dart';

TextStyle? textStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        );

ButtonStyle buttonStyle(double vertical, double horizontal) {
  const Color sari = Color.fromARGB(255, 242, 185, 29);

  return ElevatedButton.styleFrom(
      elevation: 5,
      backgroundColor: sari,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        side: const BorderSide(color: Colors.black, width: 0.7),
      ),
      shadowColor: Colors.black.withOpacity(0.3),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ));
}
