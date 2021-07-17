import 'package:flutter/material.dart';

const double _kWeatherButtonSize = 56.0;
const double _kWeatherIconSize = 36.0;

// The WeatherButton is a round material design styled button with an
// image asset as its icon.
class WeatherButton extends StatelessWidget {
  WeatherButton({required this.icon, required this.selected, required this.onPressed, Key? key}) : super(key: key);

  final String icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (selected)
      color = Theme.of(context).primaryColor;
    else
      color = const Color(0x33000000);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: _kWeatherButtonSize,
        height: _kWeatherButtonSize,
        child: FloatingActionButton(
          backgroundColor: color,
          onPressed: onPressed,
          child: Image.asset(icon, width: _kWeatherIconSize, height: _kWeatherIconSize),
        ),
      ),
    );
  }
}
