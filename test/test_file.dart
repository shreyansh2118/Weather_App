import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('getWeatherByCity returns weather data for valid city', () async {

    String apiKey = '61cb701de3e4374e4b02422588c748b5';
    String cityName = 'Ballia';

    String url = 'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';

    http.Client client = http.Client();

    http.Response response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> weatherData = jsonDecode(response.body);

      expect(weatherData['name'], isNotNull);

    } else {

      fail('Failed to fetch weather data for $cityName');
    }
  });

  test('getWeatherByCity handles error for invalid city', () async {

    String apiKey = '61cb701de3e4374e4b02422588c748b5';
    String invalidCityName = 'delhi1';

    String url = 'http://api.openweathermap.org/data/2.5/weather?q=$invalidCityName&appid=$apiKey';

    http.Client client = http.Client();

    http.Response response = await client.get(Uri.parse(url));

    expect(response.statusCode, isNot(equals(200)));
  });
}
