import 'package:flutter/material.dart';
import 'weather_demo.dart';

void main() => runApp(WeatherDemoApp());

class WeatherDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherDemo(),
    );
  }
}
