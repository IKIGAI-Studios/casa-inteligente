import 'package:flutter/material.dart';

const APP_COLORS = {
  'light': Color(0xFFF9F9F9),
  'dark': Color(0xFF1C1C1C),
  'accent': Color(0xFF2D7ABF),
};

ThemeData appTheme = ThemeData(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Lexend Deca',
  splashColor: APP_COLORS['dark'],
  colorScheme: ColorScheme.dark(
    primary: APP_COLORS['dark']!,
    secondary: APP_COLORS['light']!,
    tertiary: APP_COLORS['accent']!,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    bodySmall: TextStyle(fontSize: 20.0),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(APP_COLORS['light']!),
      backgroundColor: MaterialStateProperty.all<Color>(APP_COLORS['accent']!),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  ),
);
