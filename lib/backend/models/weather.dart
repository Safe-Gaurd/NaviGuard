class WeatherModel {
  final String name;
  final Temperature temperature;

  final int humidity;
  final Wind wind;
  final double maxTemperature;
  final double minTemperature;
  final int pressure;
  final int seaLevel;
  final List<WeatherInfo> weather;


  WeatherModel({
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.maxTemperature,
    required this.minTemperature,
    required this.pressure,
    required this.seaLevel,
    required this.weather,
  });

  static WeatherModel fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      name: json['name'],
     temperature: Temperature.fromJson(json['main']['temp']),
      humidity: json['main']['humidity'],
      wind: Wind.fromJson(json['wind']),
      maxTemperature: (json['main']['temp_max'] - 273.15),
      minTemperature: (json['main']['temp_min'] - 273.15), 
      pressure: json['main']['pressure'],
      seaLevel: json['main']['sea_level'] ?? 0,
      weather: List<WeatherInfo>.from(
        json['weather'].map(
          (weather) => WeatherInfo.fromJson(weather),
        ),
      ),
    );
  }
}

class WeatherInfo {
  final String main;

  WeatherInfo({
    required this.main,
  });

  static WeatherInfo fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      main: json['main'],
    );
  }
}

class Temperature {
  final double current;

  Temperature({required this.current});

  static Temperature fromJson(dynamic json) {
    return Temperature(
      current: (json - 273.15), 
    );
  }
}

class Wind {
  final double speed;

  Wind({required this.speed});

  static Wind fromJson(Map<String, dynamic> json) {
    return Wind(speed: json['speed']);
  }
}