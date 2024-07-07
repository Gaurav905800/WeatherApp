import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/forecast_provider.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:weather_app/screens/detail_screen.dart';

class WeatherGrid extends StatelessWidget {
  final List weatherList;
  final List forecastList;

  const WeatherGrid({
    Key? key,
    required this.weatherList,
    required this.forecastList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: weatherList.length,
      itemBuilder: (context, index) {
        final weatherIndex = weatherList[index];
        final forecast = forecastList.isNotEmpty && forecastList.length > index
            ? forecastList[index]
            : null;
        final weatherIcon = weatherIndex.weather?.isNotEmpty ?? false
            ? weatherIndex.weather![0].icon
            : null;
        return GestureDetector(
          onTap: () {
            if (forecast != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(
                    weather: weatherIndex,
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(
                '${weatherIndex.name}',
                style: const TextStyle(fontSize: 19),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weatherIndex.main?.temp} °C',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (weatherIcon != null)
                    Image.network(
                      'https://openweathermap.org/img/wn/$weatherIcon@2x.png',
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context
                          .read<WeatherProvider>()
                          .deleteWeather(context, index);
                      context.read<ForecastProvider>().deleteForecast(index);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
