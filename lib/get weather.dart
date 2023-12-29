import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _Cityname = '';
  String _tempInfo = '';
  String _windInfo = '';
  String _currweathertype = '';
  String mainCondition = '';
  late double latitude;
  late double longitude;
  TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getLocationWeather() async {
    try {
      //get location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // Get device location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (position != null) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });

        await fetchWeatherData();
      }
    } catch (e) {
      print('Error getting device location: $e');
    }
  }

  Future<void> fetchWeatherData() async {
    if (latitude != null && longitude != null) {
      String apiKey = '61cb701de3e4374e4b02422588c748b5';
      String url =
          'http://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> weatherData = jsonDecode(response.body);
        setState(() {
          _Cityname = 'Temperature in: ${weatherData['name']}';
          _currweathertype = '${weatherData['weather'][0]['main']}';
          _tempInfo =
              'Current temperature: ${(weatherData['main']['temp'] - 273.15).toStringAsFixed(2)}°C';
          _windInfo = 'wind speed ${weatherData['wind']['speed']} m/s';
        });
      } else {
        setState(() {
          _tempInfo = 'Failed to fetch weather data';
        });
      }
    }
  }

  Future<void> getCityName(String cityName) async {
    String apiKey = '61cb701de3e4374e4b02422588c748b5';
    String url =
        'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> weatherData = jsonDecode(response.body);
      setState(() {
        _Cityname = 'Temperature in: ${weatherData['name']}';
        _currweathertype = '${weatherData['weather'][0]['main']}';
        _tempInfo =
            'Current temperature: ${(weatherData['main']['temp'] - 273.15).toStringAsFixed(2)}°C';
        _windInfo = 'wind speed ${weatherData['wind']['speed']} m/s';
      });
    } else {
      setState(() {
        _tempInfo = 'Failed to fetch weather data';
      });
    }
  }

  String getweatherAnimation(_currweathertype) {
    if (_currweathertype == null) return 'assets/sunny.json';

    switch (_currweathertype.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/windy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstrom':
        return 'assets/strom.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: ListView(
          children: [
            Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter City Name",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      String cityName;
                      cityName = _cityController.text.trim();
                      getCityName(cityName);
                    },
                    child: Text("Get Weather by City")),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: getLocationWeather,
                  child: Text('Get Weather by Location'),
                ),

                Visibility(
                  visible:
                      _currweathertype != null && _currweathertype.isNotEmpty,
                  child: Lottie.asset(
                    _currweathertype != null && _currweathertype.isNotEmpty
                        ? getweatherAnimation(_currweathertype)
                        : 'assets/empty_animation.json',
                    width: 200,
                    height: 200,
                    // other Lottie animation properties
                  ),
                  replacement: Text('No data'),
                ),
                SizedBox(height: 10),
                Text(
                  _currweathertype,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  'Weather Information:',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  _Cityname,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  _tempInfo,
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  _windInfo,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
