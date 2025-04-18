import 'package:flutter/material.dart';

class CustomRow extends StatelessWidget {
  const CustomRow({
    super.key,
    required this.message1,
    required this.message2,
  });

  final String message1;
  final String message2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message1,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis, // Uzun metni üç nokta ile kes
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          message2,
          style: const TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
