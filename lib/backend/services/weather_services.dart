import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:navigaurd/backend/models/weather.dart';

class WeatherServices {
  fetchWeather() async {
    final response = await http.get(
      Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=16.568842551504964&lon=81.52600856560731&appid=36b222ee5cc0a2ccd4163f903bf8b1f8"),
    );
    // now we can cange latitude and longitude and let's see how it perfrom.
    try {
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        return WeatherModel.fromJson(json);
      } else {
        throw Exception('Failed to load Weather data');
      }
    } catch (e) {
      // print(e.toString());
    }
  }
}