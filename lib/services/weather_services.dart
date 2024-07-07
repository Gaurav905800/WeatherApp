import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart';

class WeatherService {
  String apiUrl = dotenv.get('API_URL', fallback: '');
  String apiKey = dotenv.get("API_KEY", fallback: '');
  String forecastUrl = dotenv.get("BASE_URL_DAILY_FORECAST", fallback: '');

  Future<WeatherModel?> fetchWeather(String cityName) async {
    final url = '$apiUrl?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<ForecastModel?> fetchForecast(String cityName) async {
    final url = '$forecastUrl?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return ForecastModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }
}
