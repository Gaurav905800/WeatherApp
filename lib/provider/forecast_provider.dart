import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/services/weather_services.dart';

class ForecastProvider with ChangeNotifier {
  final List<ForecastModel> _forecastList = [];
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;

  List<ForecastModel> get forecastList => _forecastList;
  bool get isLoading => _isLoading;

  ForecastProvider() {
    _loadForecastsFromStorage();
  }

  Future<void> fetchForecast(String cityName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final forecast = await WeatherService().fetchForecast(cityName);
      if (forecast != null) {
        _forecastList.add(forecast);
        await _saveForecastsToStorage();
      } else {}
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForecastList() async {
    _forecastList.clear();
    await _secureStorage.delete(key: 'forecasts');
    notifyListeners();
  }

  void deleteForecast(int index) async {
    if (index >= 0 && index < _forecastList.length) {
      _forecastList.removeAt(index);
      await _saveForecastsToStorage();
      notifyListeners();
    }
  }

  Future<void> _saveForecastsToStorage() async {
    final forecastsJson =
        jsonEncode(_forecastList.map((forecast) => forecast.toJson()).toList());
    await _secureStorage.write(key: 'forecasts', value: forecastsJson);
  }

  Future<void> _loadForecastsFromStorage() async {
    final forecastsJson = await _secureStorage.read(key: 'forecasts');
    if (forecastsJson != null) {
      final List<dynamic> decodedJson = jsonDecode(forecastsJson);
      _forecastList.addAll(
          decodedJson.map((json) => ForecastModel.fromJson(json)).toList());
      notifyListeners();
    }
  }
}
