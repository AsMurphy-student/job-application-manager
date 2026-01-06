import 'package:flutter/material.dart';

final ThemeData deepBurgundyTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7B1FA2), // Deep magenta
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFC62828), // Dark red
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFF1B0A1B), // Very dark purple
    onBackground: Color(0xFFFFFFFF),
    surface: Color(0xFF2C112C), // Slightly lighter
    onSurface: Color(0xFFFFFFFF),
    error: Color(0xFFFF6F00), // Bright orange‑red
    onError: Color(0xFFFFFFFF),
  ),
  // textTheme: const TextTheme(
  //   headline1: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
  //   bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
  // ),
);
