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
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonWidth = screenWidth * .25;
    double buttonHeight = screenHeight * 0.12;
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
              SizedBox(height: buttonHeight*0.05),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
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