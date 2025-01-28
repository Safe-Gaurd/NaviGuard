import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget 
{

  final Color? backgroundColor;
  final Color? foregroundColor;
  final String text;
  final VoidCallback? onPressed;

  const CustomTextButton({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    required this.text,
    required this.onPressed,
    
    });

  @override
  Widget build(BuildContext context) {
    return TextButton
            (
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(backgroundColor),
                foregroundColor: WidgetStatePropertyAll(foregroundColor),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                  ),
                )
                ),
              onPressed: onPressed,
              child: Text(text),
            );
  }
}