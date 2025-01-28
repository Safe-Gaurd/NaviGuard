import 'package:flutter/material.dart';
import 'package:navigaurd/screens/home/widgets/custom_card_button.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        children: [
          CustomCardButton(
            title: "Weather",
            imagePath: "assets/home/weather.JPG",
            gradient: LinearGradient(colors: [Colors.blue[300]!, Colors.blue[600]!]),
          ),
          CustomCardButton(
            title: "Start Journey",
            imagePath: "assets/home/maps.jpg",
            width: 85,
            height: 85,
            gradient: LinearGradient(colors: [Colors.green[300]!, Colors.green[600]!]),
          ),
          CustomCardButton(
            title: "Emergency",
            imagePath: "assets/home/emergency.jpg",
            gradient: LinearGradient(colors: [Colors.red[300]!, Colors.red[600]!]),
          ),
          CustomCardButton(
            title: "Reports Analysis",
            imagePath: "assets/home/accident_analysis.jpg",
            width: 85,
            height: 85,
            gradient: LinearGradient(colors: [Colors.orange[300]!, Colors.orange[600]!]),
          ),
        ],
      ),
    );
  }

}