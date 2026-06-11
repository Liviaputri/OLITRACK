import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF070B1A);
  static const card = Color(0xFF0F1630);
  static const accent = Colors.orange;

  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: bg,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white12,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
  );
}