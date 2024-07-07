import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<WeatherModel> _weatherList = [];
  bool isLoading = false;

  List<WeatherModel> get weatherList => _weatherList;

  WeatherProvider() {
    _loadWeatherList();
  }

  Future<void> _loadWeatherList() async {
    final savedWeather = await _storage.read(key: 'weather_list');
    if (savedWeather != null) {
      _weatherList = WeatherModel.decode(savedWeather);
      notifyListeners();
    }
  }

  Future<void> searchWeather(BuildContext context, String city) async {
    isLoading = true;
    notifyListeners();

    final response = await _weatherService.fetchWeather(city);
    if (response != null) {
      bool isAlreadyAdded = _weatherList.any(
        (weather) => weather.name?.toLowerCase() == city.toLowerCase(),
      );
      if (isAlreadyAdded) {
        // ignore: use_build_context_synchronously
        _showErrorSnackBar(context, 'City already added');
      } else {
        _weatherList.insert(0, response);
        await _saveWeatherList();
        notifyListeners();
      }
    } else {
      // ignore: use_build_context_synchronously
      _showErrorSnackBar(context, 'Failed to load weather data');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    isLoading = true;
    notifyListeners();

    List<WeatherModel> updatedWeatherList = [];
    for (WeatherModel weather in _weatherList) {
      final response = await _weatherService.fetchWeather(weather.name!);
      if (response != null) {
        updatedWeatherList.add(response);
      } else {
        updatedWeatherList.add(weather);
      }
    }

    _weatherList = updatedWeatherList;
    await _saveWeatherList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveWeatherList() async {
    final encodedData = WeatherModel.encode(_weatherList);
    await _storage.write(key: 'weather_list', value: encodedData);
  }

  void clearWeatherList() {
    _weatherList.clear();
    _storage.delete(key: 'weather_list');
    notifyListeners();
  }

  void deleteWeather(BuildContext context, int index) {
    if (index >= 0 && index < _weatherList.length) {
      _weatherList.removeAt(index);
      _saveWeatherList();
      notifyListeners();
    } else {
      _showErrorSnackBar(context, 'Invalid index');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}
