import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/home/home.dart';
import 'package:navigaurd/screens/onboarding/onboarding_main.dart';


class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {

  @override
  @override
void initState() {
  super.initState(); 

  Future.delayed(const Duration(seconds: 8), () {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OnboardingMainScreen(),
        ),
      );
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCEEF3),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100,),
          const Text("NaviGaurd", style: TextStyle(fontSize: 30, color: blueColor, fontWeight: FontWeight.bold),),
          const SizedBox(height: 5,),
          const Text("Your Travelling Companion", style: TextStyle(fontSize: 20, color: blueColor, fontWeight: FontWeight.bold),),
          const SizedBox(height: 60,),
          Image.asset("assets/onboarding_screen/app_logo.jpg", width: double.infinity,height: 200,),
          const SizedBox(height: 10,),
          Lottie.asset('assets/splash_screen/splashscreen_lottie.json',
          width: 300,
          height: 250
          ),
        ],
      ),
    );
  }
}