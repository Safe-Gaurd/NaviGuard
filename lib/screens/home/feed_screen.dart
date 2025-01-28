import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/models/weather.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/backend/services/weather_services.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/date_time.dart';
import 'package:navigaurd/screens/feed_sub_screens/phone_call.dart';
import 'package:navigaurd/screens/feed_sub_screens/report_analysis.dart';
import 'package:navigaurd/screens/feed_sub_screens/weather.dart';
import 'package:navigaurd/screens/feed_sub_screens/weather_short_cut.dart';
import 'package:navigaurd/screens/home/widgets/custom_card_button.dart';
import 'package:navigaurd/screens/maps/map.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  late WeatherModel weatherInfo;
  bool isLoading = false;
  String weatherMessage = 'The weather is clear and perfect for driving. Enjoy the sunshine!';
  String weatherImagePath = 'assets/home/sunny.jpg';

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final value = await WeatherServices().fetchWeather();
      setState(() {
        weatherInfo = value;
        updateWeatherMessage();
        isLoading = false;
        
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateWeatherMessage() {
    if (weatherInfo.weather.isEmpty) return;

    String weatherCondition = weatherInfo.weather[0].main.toLowerCase();

    if (weatherCondition.contains('clouds')) {
      weatherMessage =
          "It's a cloudy day, but the weather is still good for driving. Stay cozy!";
      weatherImagePath = "assets/home/cloudy.jpg";
    } else if (weatherCondition.contains('rain')) {
      weatherMessage =
          "It's rainy outside. Drive carefully and keep your headlights on for safety!";
      weatherImagePath = "assets/home/rainy.jpg";
    } else {
      weatherMessage =
          "The weather is clear and perfect for driving. Enjoy the sunshine!";
      weatherImagePath = "assets/home/sunny.jpg";
    }
  }

  @override
  void initState() {
    weatherInfo = WeatherModel(
      name: '',
      temperature: Temperature(current: 21.00),
      humidity: 0,
      wind: Wind(speed: 0.0),
      maxTemperature: 0,
      minTemperature: 0,
      pressure: 0,
      seaLevel: 0,
      weather: [],
    );
    fetchWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, _) {
      return provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 45),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome!",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: backgroundColor),
                                ),
                                Text(
                                  provider.user.name,
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: backgroundColor),
                                ),
                                const SizedBox(height: 90),
                                Text(
                                  weatherMessage,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: backgroundColor),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: -15,
                            right: -25,
                            child: SizedBox(
                              width: 285,
                              height: 180,
                              child: Lottie.asset(
                                "assets/home/driving.json",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Weather Box
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : WeatherWidget(
                            weatherCondition:
                                weatherInfo.weather.isNotEmpty
                                    ? weatherInfo.weather[0].main
                                    : "Sunny",
                            temperature:
                                "${weatherInfo.temperature.current.toStringAsFixed(2)}°C",
                            date: formattedDate,
                            location: weatherInfo.name,
                            backgroundColor: Colors.white,
                            iconPath: weatherImagePath,
                          ),
                    const SizedBox(height: 20),
                    customCard(context),
                  ],
                ),
              ),
            );
    });
  }

  Widget customCard(BuildContext context) {
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
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const WeatherScreen()));
            },
            gradient: LinearGradient(
                colors: [Colors.blue[300]!, Colors.blue[600]!]),
          ),
          CustomCardButton(
            title: "Start Journey",
            imagePath: "assets/home/maps.jpg",
            width: 85,
            height: 85,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MapScreen()));
            },
            gradient: LinearGradient(
                colors: [Colors.green[300]!, Colors.green[600]!]),
          ),
          CustomCardButton(
            title: "Emergency",
            imagePath: "assets/home/emergency.jpg",
            gradient: LinearGradient(
                colors: [Colors.red[300]!, Colors.red[600]!]),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PhoneCallScreen()));
            },
          ),
          CustomCardButton(
            title: "Reports Analysis",
            imagePath: "assets/home/accident_analysis.jpg",
            width: 85,
            height: 85,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ReportAnalysisScreen()));
            },
            gradient: LinearGradient(
                colors: [Colors.orange[300]!, Colors.orange[600]!]),
          ),
        ],
      ),
    );
  }
}
