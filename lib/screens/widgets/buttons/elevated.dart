import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';

class CustomElevatedButton extends StatelessWidget 
{

  final Color? backgroundColor;
  final Color? foregroundColor;
  final String text;
  final VoidCallback? onPressed;
  final double? borderRadius;
  final TextStyle? textStyle;
  bool isIcon;
  final IconData? icon;

  CustomElevatedButton({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    required this.text,
    this.onPressed,
    this.textStyle,
    this.isIcon = false,
    this.icon,
    
    });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton
            (
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(backgroundColor ?? blueColor),
                foregroundColor: WidgetStatePropertyAll(foregroundColor ?? backgroundColor),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  ),
                )
                ),
              onPressed: onPressed,
              child: isIcon
              ? Icon(icon, color: Colors.white,)
              : Text(text, style: textStyle,),
            );
  }
}