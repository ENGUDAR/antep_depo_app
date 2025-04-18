import 'package:antep_depo_app/constants/project_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomFilterchip extends StatelessWidget {
  const CustomFilterchip({
    super.key,
    required this.ref,
    required this.option2,
    this.onSelected,
    required this.message,
  });
  final WidgetRef ref;
  final bool option2;
  final Function(bool)? onSelected;
  final String message;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      //side: BorderSide(color: loginColors),
      elevation: 15,
      label: Text(
        message,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black),
      ),
      selected: option2,
      onSelected: onSelected,
      selectedColor: loginColors.withOpacity(0.2),
    );
  }
}
