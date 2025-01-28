import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';

class WeatherWidget extends StatelessWidget {
  final String weatherCondition;
  final String temperature;
  final String date;
  final String location;
  final Color backgroundColor;
  final String iconPath;

  const WeatherWidget({
    super.key,
    required this.weatherCondition,
    required this.temperature,
    required this.date,
    required this.location,
    required this.backgroundColor,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weatherCondition,
                style: const TextStyle(
                  color: blueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                temperature,
                style: const TextStyle(
                  color: blueColor,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: blueColor, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      color: blueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, color: blueColor, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    location,
                    style: const TextStyle(
                      color: blueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Weather Icon Section
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              iconPath,
              fit: BoxFit.cover,
              width: 130,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}