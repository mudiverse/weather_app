import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//my own classes
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Hourly_Forecast_Item.dart';
import 'package:weather_app/Additional_Information_item.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather ;
  Future <Map<String,dynamic>>getCurrentWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
      ));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error!';
      }
      return data;

    } catch (e) {
      throw e.toString();
    }
  }
  @override
  void initState() {

    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Weather',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: RefreshProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp =    currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWinds = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];


          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                ///main card starts here
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                              currentSky == 'Cloud' || currentSky == 'Rain'  ? Icons.cloud : Icons.sunny ,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// leaving some gap
                const SizedBox(height: 20),

                ///weather forecast cards
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Weather Forecast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ///scrollable cards
                // const SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       HourlyForecastItem(
                //         icon: Icons.cloud,
                //         time: '03:00',
                //         temperature: '321.69',
                //       ),
                //
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder:(context,index){
                        final hourlyForecast = data['list'][index+1];
                        final hourlySky = data['list'][index+1]['weather'][0]['main'];
                        final hourlyTemp = hourlyForecast['main']['temp'].toString();

                        final time = DateTime.parse(hourlyForecast['dt_txt']);

                        return HourlyForecastItem
                          (time: DateFormat.j().format(time),
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rain' ? Icons.cloud : Icons.sunny,
                            temperature: hourlyTemp
                        );
                      }
                  ),
                ),

                const SizedBox(height: 20),

                ///Additional Infromation
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // SizedBox(width: 32),
                    AdditionalInformationItem(
                      icon: Icons.water_drop,
                      amount:currentHumidity.toString() ,
                      info: 'Humidity',
                    ),
                     AdditionalInformationItem(
                      icon: Icons.air,
                      amount: currentWinds.toString(),
                      info: 'Wind Speed',
                    ),
                    AdditionalInformationItem(
                      icon: Icons.home,
                      amount: currentPressure.toString(),
                      info: 'Pressure',
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
