import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    // themeMode: ThemeMode.dark,
    primaryColor: Colors.black, // Text
    hintColor: Colors.black, // Hints
    dividerColor: Colors.white,
    scaffoldBackgroundColor: Colors.white, // Background
    canvasColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.blueGrey,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.black,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey),
    ),
  );
}
