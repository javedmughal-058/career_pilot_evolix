import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const fontFamily = 'Urbanist';
  static const primary = Color(0xFF0057FF);
  static const primaryDark = Color(0xFF003BB3);
  static const secondary = Color(0xFF00B8FF);
  static const background = Color(0xFFF4FAFF);
  static const ink = Color(0xFF071B3A);
  static const muted = Color(0xFF60738C);
  static const evolixGreen = Color(0xFF00B8FF);

  static ThemeData light(double textScaleFactor) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: primary,
            secondary: secondary,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          ),
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
    );
    final urbanist = base.textTheme.apply(fontFamily: fontFamily);
    return base.copyWith(
      textTheme: urbanist
          .apply(bodyColor: ink, displayColor: ink)
          .copyWith(
            headlineLarge: urbanist.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: urbanist.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            titleLarge: urbanist.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            titleMedium: urbanist.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFDDF6FF),
        height: 70,
      ),
    );
  }
}
