import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFFD700); // Yellow
  static const Color secondaryColor = Color(0xFFFFC107); // Amber
  static const Color backgroundColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF252525);

  // Trading specific colors
  static const Color positiveColor = Color(
    0xFF4CAF50,
  ); // Green for buy/price increase
  static const Color negativeColor = Color(
    0xFFF44336,
  ); // Red for sell/price decrease
  static const Color neutralColor = Color(
    0xFFE0E0E0,
  ); // Gray for neutral indicators

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFFFFD700), // Primary yellow
    Color(0xFFFFC107), // Amber
    Color(0xFF03DAC6), // Teal
    Color(0xFF018786), // Dark teal
    Color(0xFFFFB74D), // Orange
    Color(0xFF64B5F6), // Blue
  ];

  static ThemeData darkTheme() {
    final darkTextTheme = ThemeData.dark().textTheme;
    final textTheme = GoogleFonts.interTextTheme(darkTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: negativeColor,
      ),
      // Text theme with Google Fonts
      textTheme: textTheme,

      // Card theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primaryColor.withOpacity(0.2),
        backgroundColor: cardColor,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return textTheme.bodyMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            );
          }
          return textTheme.bodyMedium?.copyWith(color: Colors.white70);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: Colors.white70);
        }),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white60,
      ),
    );
  }

  static ThemeData lightTheme() {
    // For future implementation of a light theme
    return darkTheme();
  }
}
