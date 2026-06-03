import 'package:flutter/material.dart';
import 'theme_constants.dart';

class AppThemes {
  // Light ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary,
        surface: AppColors.lightSurface,
        surfaceContainerLow: const Color(0xFFF4F4F4), // ✓ PopularItemCard bg
        surfaceContainerHighest: const Color(0xFFE9E9E9), // ✓ arrow circle bg
        onSurfaceVariant: const Color(0xFF8E8E8E), // ✓ subtitle & icon color
        shadow: Colors.black,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headline,
        bodyLarge: AppTypography.bodyPrimary,
        bodyMedium: AppTypography.bodySecondary,
      ).apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
    );
  }

  // Dark ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        surface: AppColors.darkSurface,
        surfaceContainerLow: const Color(0xFF2A2A2A), // ✓ dark card bg
        surfaceContainerHighest: const Color(0xFF3A3A3A), // ✓ dark arrow circle
        onSurfaceVariant: const Color(0xFF9E9E9E), // ✓ dark subtitle
        shadow: Colors.black,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headline,
        bodyLarge: AppTypography.bodyPrimary,
        bodyMedium: AppTypography.bodySecondary,
      ).apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
    );
  }
}
