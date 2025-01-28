import 'package:flutter/material.dart';
import 'package:navigaurd/screens/auth/login.dart';
import 'package:navigaurd/screens/onboarding/widgets/onboarding_sub.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';
import 'package:navigaurd/screens/widgets/buttons/textfield.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingMainScreen extends StatefulWidget {
  const OnboardingMainScreen({super.key});

  @override
  State<OnboardingMainScreen> createState() => OnboardingMainScreenState();
}

class OnboardingMainScreenState extends State<OnboardingMainScreen> {
  final PageController controller = PageController(initialPage: 0);
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 3; 
              });
            },
            children: [
              OnboardingSubScreen(
                title: "Welcome to NaviGaurd!", 
                isLottie: true, 
                address: "assets/onboarding_screen/screen1.json", 
                description: "Your safety on the road is our priority. SafeRoads is designed to help drivers and commuters reduce the risk of accidents and ensure a safer journey for everyone.",
                backgroundColor: Colors.blueAccent[100]
              ),

              OnboardingSubScreen(
                title: "Stay Informed with Real-Time Alerts", 
                isLottie: true, 
                address: "assets/onboarding_screen/screen2.json", 
                description: "Get instant notifications about road hazards, weather conditions, and accident-prone zones. Be prepared and stay ahead to avoid risks.",
                backgroundColor: Colors.indigo[100]
              ),

              OnboardingSubScreen(
                title: "Your Reliable Dashcam Companion", 
                isLottie: false, 
                address: "assets/onboarding_screen/screen3.jpg", 
                description: "Secure your journey with real-time dashcam access, protecting against false accusations and simplifying insurance claims.",
                backgroundColor: Colors.lightGreen[100]
              ),

              const OnboardingSubScreen(
                title: "Quick Emergency Assistance", 
                isLottie: false, 
                address: "assets/onboarding_screen/screen4.png", 
                description: "In case of emergencies, SafeRoads connects you with nearby help and alerts your emergency contacts instantly.",
              ),
            ],
          ),

          Positioned(
            bottom: 90,
            left:160,
            child: SmoothPageIndicator(
              controller: controller,
              count: 4,
              effect: const WormEffect(),
              onDotClicked: (index) {
                controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),


          isLastPage
          ? Positioned(
            bottom: 25,
            left: 150,
            child: CustomElevatedButton(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          text: "Get Started",
                        ),
          )
          : 
            Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: 
                  [
                     CustomTextButton(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      text: "Skip",
                      onPressed: () {
                          controller.jumpToPage(3);
                        },
                      ),
                    CustomTextButton(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      text: "Next",
                      onPressed: () {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
