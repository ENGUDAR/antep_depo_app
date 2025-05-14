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
  final Color sari = const Color.fromARGB(255, 242, 185, 29);

  @override
  void initState() {
    super.initState();
    _isObscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextFormField(
        obscureText: _isObscureText,
        controller: widget.controller,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.black, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          suffixIcon: widget.isObscure
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscureText = !_isObscureText;
                    });
                  },
                  icon: Icon(
                    _isObscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: sari,
                    size: 22,
                  ),
                )
              : null,
          prefixIcon: Icon(
            widget.icon,
            color: sari,
            size: 22,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelText: widget.message,
          labelStyle: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: sari, fontWeight: FontWeight.w500),
          floatingLabelStyle: TextStyle(
            color: sari,
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: sari, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: sari, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
