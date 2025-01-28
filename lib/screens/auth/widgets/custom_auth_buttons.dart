import 'package:flutter/material.dart';

class LoginSignupButtons extends StatelessWidget 
{
  final String? imagepath;
  final String label;
  final void Function()? onTap;
  final bool isLoading;
  final Color? backgroundColor;

  const LoginSignupButtons({super.key,
  this.imagepath,
  required this.label,
  required this.onTap,
  this.isLoading = false,
  this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(

        onPressed: isLoading ? null : onTap, 
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: Colors.blue, width: 2),
          backgroundColor: backgroundColor ?? Colors.white,
        ),
        child: SizedBox(
          width: 200,
          height: 43,
          child: 
          isLoading
          ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue[800],
                  strokeWidth: 2.0,
                ),
              )
          : imagepath==null
              ? Center(child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)))
              : Row(
                  children: [
                    ClipOval(
                      child: Image.asset(imagepath!, height: 35)),
                    const SizedBox(width: 10,),
                    Text(label, style: TextStyle(fontSize: 16, color: Colors.blue[800]),)
                  ],  
                ),
        )
      );
  }
}