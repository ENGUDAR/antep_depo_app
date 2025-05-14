import 'package:flutter/material.dart';

class CustomRow extends StatelessWidget {
  final String message1;
  final String message2;
  const CustomRow({super.key, required this.message1, required this.message2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          message1,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          message2,
          style: const TextStyle(fontSize: 17),
        )
      ],
    );
  }
}
