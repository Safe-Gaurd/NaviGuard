import 'package:flutter/material.dart';
import 'package:navigaurd/backend/models/weather.dart';
import 'package:navigaurd/backend/services/weather_services.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';
import 'package:navigaurd/constants/date_time.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> 
{
  late WeatherModel weatherInfo;
  bool isLoading = false;
  myWeather() {
    setState(() {
      isLoading = true;
    });
    WeatherServices().fetchWeather().then((value) {
      setState(() {
        weatherInfo = value;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    weatherInfo = WeatherModel(
      name: '',
      temperature: Temperature(current: 0.0),
      humidity: 0,
      wind: Wind(speed: 0.0),
      maxTemperature: 0,
      minTemperature: 0,
      pressure: 0,
      seaLevel: 0,
      weather: [],
    );
    myWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(label: "Weather"),
      backgroundColor: Colors.blue[100],
      body: Center(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
            : SingleChildScrollView(
              child: Column(
                children: [
                  WeatherDetail(
                      weather: weatherInfo,
                      formattedDate: formattedDate,
                      formattedTime: formattedTime,
                    ),
                    const SizedBox(height: 20,),
                ],
              ),
            ),
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final WeatherModel weather;
  final String formattedDate;
  final String formattedTime;
  final String imagePath="assets/weather/sunny.jpg";
  const WeatherDetail({
    super.key,
    required this.weather,
    required this.formattedDate,
    required this.formattedTime,
  });

  String updateImagePath()
  {
    if(weather.weather[0].main.contains("Clouds"))
    {
      return "assets/weather/cloudy.jpg";
    }
    else if(weather.weather[0].main.contains("Rain"))
    {
      return "assets/weather/rainy.jpg";
    }  
    else
    {
      return "assets/weather/sunny.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
        height: 350,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with reduced opacity
              ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.15), BlendMode.darken),
                child: Image.asset(
                  updateImagePath(),
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
              // Column for text
              Align(
                alignment: Alignment.centerRight, 
                child: Padding(
                  padding: const EdgeInsets.all(16.0), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Current temperature
                      Text(
                        "${weather.temperature.current.toStringAsFixed(2)}°C",
                        style: const TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, // Align icon and text to the right
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 30,
                            color: Colors.white,
                          ),
                          Text(
                            weather.name,
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      // for current date and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (weather.weather.isNotEmpty)
                        Text(
                          weather.weather[0].main,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
                    ],
                  ),
                ),
              ),
      
          const SizedBox(height: 10),
          
          // for more weather detail
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      weatherInfoCard(
                          icon:  const Icon(Icons.wind_power,color: Colors.white),
                          title: "Wind", value: "${weather.wind.speed}km/h"
                        ),
                      weatherInfoCard(
                        icon: const Icon(Icons.sunny,color: Colors.yellow),
                        title: "Max",
                        value:"${weather.maxTemperature.toStringAsFixed(2)}°C"),
                      weatherInfoCard(
                        icon: const Icon(Icons.sunny,color: Colors.yellow),
                        title: "Min",
                        value:"${weather.minTemperature.toStringAsFixed(2)}°C"),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      weatherInfoCard(
                        icon: const Icon(Icons.water_drop,color: Colors.blue),
                        title: "Humidity", 
                        value: "${weather.humidity}%"),
                      weatherInfoCard(
                        icon: const Icon(Icons.air,color: Colors.white),
                        title: "Pressure", 
                        value: "${weather.pressure}hPa"),
                      weatherInfoCard(
                        icon: const Icon(Icons.waves,color: Colors.blue),
                        title: "Sea-Level", 
                        value: "${weather.seaLevel}m"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Column weatherInfoCard({
    required Icon icon,
    required String title, 
    required String value
  })
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(height: 5),
        Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        )
      ],
        )
      ],
    );
  }
}