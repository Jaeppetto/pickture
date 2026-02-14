import 'package:flutter/material.dart';

abstract final class AppColors {
  // === Light Mode ===
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F5);
  static const lightPrimary = Color(0xFF2D5BFF);
  static const lightSecondary = Color(0xFF7C3AED);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF8E8E93);

  // === Dark Mode ===
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkPrimary = Color(0xFF4D7AFF);
  static const darkSecondary = Color(0xFFA78BFA);
  static const darkTextPrimary = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFF8E8E93);

  // === Semantic Colors ===
  static const delete = Color(0xFFFF3B30);
  static const deleteDark = Color(0xFFFF453A);
  static const keep = Color(0xFF34C759);
  static const keepDark = Color(0xFF30D158);
  static const favorite = Color(0xFFFF9500);
  static const favoriteDark = Color(0xFFFFa726);

  // === Gradients ===
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2D5BFF), Color(0xFF7C3AED)],
  );

  static const deleteGradient = LinearGradient(
    colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
  );

  static const keepGradient = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF7AE5A0)],
  );

  static const favoriteGradient = LinearGradient(
    colors: [Color(0xFFFF9500), Color(0xFFFFD60A)],
  );
}
