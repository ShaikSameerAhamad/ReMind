import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class ReMindTheme {
  static ThemeData light() => _theme(
        brightness: Brightness.light,
        background: ReMindColors.cloud,
        surface: ReMindColors.white,
        onSurface: ReMindColors.ink,
      );

  static ThemeData dark() => _theme(
        brightness: Brightness.dark,
        background: ReMindColors.ink,
        surface: ReMindColors.darkSurface,
        onSurface: ReMindColors.cloud,
      );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ReMindColors.sky,
      brightness: brightness,
    ).copyWith(
      primary: ReMindColors.sky,
      onPrimary: ReMindColors.ink,
      secondary: ReMindColors.mint,
      onSecondary: ReMindColors.ink,
      surface: surface,
      onSurface: onSurface,
      error: ReMindColors.error,
      outline: ReMindColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Onest',
      textTheme: _textTheme(onSurface),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: textColor),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textColor),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
    );
  }
}
