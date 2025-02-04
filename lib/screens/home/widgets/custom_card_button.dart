import 'package:flutter/material.dart';

class CustomCardButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final LinearGradient? gradient;
  final void Function()? onTap;
  final double? width;
  final double? height;

  const CustomCardButton({
    super.key,
    required this.title,
    required this.imagePath,
    this.gradient,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * .25;
    double buttonHeight = screenWidth * 0.25;
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  imagePath,
                  width: width ?? buttonWidth,
                  height: height ?? buttonHeight,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
