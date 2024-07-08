import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/forecast_provider.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:weather_app/screens/detail_screen.dart';
import 'package:weather_app/widgets/custom_search_bar.dart';
import 'package:weather_app/widgets/grid_view.dart';
import 'package:weather_app/widgets/list_view.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WeatherProvider>().refreshWeather();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Consumer2<WeatherProvider, ForecastProvider>(
          builder: (context, weatherProvider, forecastProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchBar(
                  controller: _controller,
                  onPressed: () async {
                    final city = _controller.text;
                    if (city.isNotEmpty) {
                      bool isSuccess =
                          await weatherProvider.searchWeather(context, city);
                      if (isSuccess) {
                        await forecastProvider.fetchForecast(city);
                        final weather = weatherProvider.weatherList[0];
                        final forecast1 = forecastProvider.forecastList[0];

                        if (weather.name != null &&
                            forecast1.city?.name != null) {
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                weather: weather,
                              ),
                            ),
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Weather data not available for "$city"'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      _controller.clear();
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (weatherProvider.weatherList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent watch',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            weatherProvider.clearWeatherList();
                            forecastProvider.clearForecastList();
                          },
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                  ),
                if (weatherProvider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (weatherProvider.weatherList.isEmpty &&
                    !weatherProvider.isLoading)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No weather data available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                if (weatherProvider.weatherList.isNotEmpty)
                  Expanded(
                    child: isTablet || isLandscape
                        ? WeatherGrid(
                            weatherList: weatherProvider.weatherList,
                            forecastList: forecastProvider.forecastList,
                          )
                        : WeatherListView(
                            weatherList: weatherProvider.weatherList,
                            forecastList: forecastProvider.forecastList,
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
