import 'package:flutter/material.dart';

import 'package:pickture/core/theme/app_colors.dart';
import 'package:pickture/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    delete: AppColors.delete,
    keep: AppColors.keep,
    favorite: AppColors.favorite,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    delete: AppColors.deleteDark,
    keep: AppColors.keepDark,
    favorite: AppColors.favoriteDark,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color secondary,
    required Color textPrimary,
    required Color textSecondary,
    required Color delete,
    required Color keep,
    required Color favorite,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: delete,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: textPrimary),
        headlineMedium: AppTextStyles.headline.copyWith(color: textPrimary),
        titleLarge: AppTextStyles.title.copyWith(color: textPrimary),
        titleMedium: AppTextStyles.titleSmall.copyWith(color: textPrimary),
        bodyLarge: AppTextStyles.body.copyWith(color: textPrimary),
        bodyMedium: AppTextStyles.bodySmall.copyWith(color: textSecondary),
        labelSmall: AppTextStyles.caption.copyWith(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
