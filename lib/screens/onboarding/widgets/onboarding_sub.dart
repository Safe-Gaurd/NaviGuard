import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingSubScreen extends StatelessWidget 
{

  final String title;
  final bool isLottie;
  final String address;
  final String description;
  final Color? backgroundColor;

  const OnboardingSubScreen({
    super.key,
    required this.title,
    required this.isLottie,
    required this.address,
    required this.description,
    this.backgroundColor,
    });
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        
            isLottie 
            ? Lottie.asset(
              address,
              height: 330, 
              width: 420,
              )
            : Column(
              children: [
                const SizedBox(height: 15,),
                Image.asset(
                address,
                height: 300,
                width: 400,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 15,),

              ],
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                description,                
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
