import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String message;
  final String errorMessage;
  final IconData icon;
  final bool isObscure;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.message,
    required this.errorMessage,
    required this.icon,
    required this.isObscure,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscureText;

  @override
  void initState() {
    super.initState();
    _isObscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        obscureText: _isObscureText,
        controller: widget.controller,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
        decoration: InputDecoration(
          suffixIcon: widget.isObscure
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscureText = !_isObscureText;
                    });
                  },
                  icon: Icon(
                    _isObscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                )
              : null,
          prefixIcon: Icon(
            widget.icon,
            color: const Color.fromARGB(255, 95, 128, 31),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          labelText: widget.message,
          labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color.fromARGB(255, 95, 128, 31)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color.fromARGB(255, 95, 128, 31)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color.fromARGB(255, 95, 128, 31)),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return widget.errorMessage;
          }
          return null;
        },
      ),
    );
  }
}
