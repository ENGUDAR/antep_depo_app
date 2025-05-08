import 'package:antep_depo_app/constants/project_colors.dart';
import 'package:flutter/material.dart';

TextStyle? textStyle(BuildContext context) => Theme.of(context).textTheme.titleLarge;
ButtonStyle buttonStyle(double vertical, double horizontal) {
  return ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 242, 185, 29),
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
}
