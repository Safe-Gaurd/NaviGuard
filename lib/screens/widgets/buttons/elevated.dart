import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget 
{

  final Color? backgroundColor;
  final Color? foregroundColor;
  final String text;
  final VoidCallback? onPressed;
  final double? borderRadius;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    required this.text,
    this.onPressed,
    this.textStyle,
    
    });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton
            (
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(backgroundColor ?? Colors.blue[100]),
                foregroundColor: WidgetStatePropertyAll(foregroundColor ?? Colors.black),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  ),
                )
                ),
              onPressed: onPressed,
              child: Text(text, style: textStyle,),
            );
  }
}