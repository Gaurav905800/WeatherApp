import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/provider/forecast_provider.dart';

class DetailPage extends StatelessWidget {
  final WeatherModel weather;

  const DetailPage({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('${weather.name}'),
      ),
      body: Consumer<ForecastProvider>(
        builder: (context, forecastProvider, child) {
          final forecast = forecastProvider.forecastList.firstWhere(
            (f) => f.city?.name?.toLowerCase() == weather.name?.toLowerCase(),
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isTablet = constraints.maxWidth > 600;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${weather.weather?[0].description} ',
                            style: const TextStyle(fontSize: 25),
                          ),
                          Text(
                            '${weather.main?.temp}°C',
                            style: const TextStyle(fontSize: 25),
                          ),
                          const SizedBox(height: 20),
                          Image.network(
                            'https://openweathermap.org/img/wn/${weather.weather?[0].icon}@4x.png',
                          ),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Humidity: ${weather.main?.humidity ?? "N/A"}%',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Wind Speed: ${weather.wind?.speed ?? "N/A"} m/s',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      isTablet || isLandscape
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: forecast.list?.length,
                              itemBuilder: (context, index) {
                                final dayForecast = forecast.list?[index];
                                final date = DateFormat('EEE, MMM d').format(
                                    DateTime.parse(dayForecast!.dtTxt!));
                                final time = DateFormat('h:mm a')
                                    .format(DateTime.parse(dayForecast.dtTxt!));
                                final temp = dayForecast.main?.temp
                                        ?.toStringAsFixed(1) ??
                                    'N/A';
                                final weatherDescription =
                                    dayForecast.weather?.first.description ??
                                        'N/A';
                                final weatherIcon =
                                    dayForecast.weather?.first.icon ?? '';

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade300,
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    leading: Image.network(
                                      'https://openweathermap.org/img/wn/$weatherIcon@2x.png',
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                    title: Text(
                                      date,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text('$temp°C - $weatherDescription'),
                                    trailing: Text(
                                      time,
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: forecast.list?.length,
                              itemBuilder: (context, index) {
                                final dayForecast = forecast.list?[index];
                                final date = DateFormat('EEE, MMM d').format(
                                    DateTime.parse(dayForecast!.dtTxt!));
                                final time = DateFormat('h:mm a')
                                    .format(DateTime.parse(dayForecast.dtTxt!));
                                final temp = dayForecast.main?.temp
                                        ?.toStringAsFixed(1) ??
                                    'N/A';
                                final weatherDescription =
                                    dayForecast.weather?.first.description ??
                                        'N/A';
                                final weatherIcon =
                                    dayForecast.weather?.first.icon ?? '';

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade300,
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    leading: Image.network(
                                      'https://openweathermap.org/img/wn/$weatherIcon@2x.png',
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                    title: Text(
                                      date,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text('$temp°C - $weatherDescription'),
                                    trailing: Text(
                                      time,
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
