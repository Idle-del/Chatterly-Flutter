import 'package:flutter/material.dart';

class AppThemes {
  // Define light theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.purple[800],
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple[800]!,
      brightness: Brightness.light,
      primary: Colors.purple[800]!,
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple[800],
      unselectedItemColor: Colors.grey,
    ),
  );

  // Define dark theme
  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.purple[800],
    scaffoldBackgroundColor: Color(0xFF121212),
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple[800]!,
      brightness: Brightness.dark,
      primary: Colors.purple[800]!,
      surface: Color(0xFF121212),
    ),
    cardColor: Color(0xFF121212),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF121212),
      selectedItemColor: Colors.purple[800],
      unselectedItemColor: Colors.grey,
    ),
  );
}
