import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hinttext;
  final TextEditingController controller;
  final bool isobsure;
  final TextInputType? keyboard;
  final IconData prefixicon;
  final Widget? suffixicon;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hinttext,
    required this.controller,
    this.isobsure=false,
    this.keyboard=TextInputType.name,
    required this.prefixicon,
    this.suffixicon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hinttext,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.blue[600] ?? Colors.blue,
              width: 2,
            ),
          ),
          fillColor: Colors.grey[200],
          filled: true,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          floatingLabelStyle: TextStyle(color: Colors.blue[600] ?? Colors.blue), 
          prefixIcon: Icon(prefixicon),
          suffixIcon: suffixicon,
        ),
        validator: validator,
        obscureText: isobsure,
        keyboardType: keyboard,
      ),
    );
  }
}
