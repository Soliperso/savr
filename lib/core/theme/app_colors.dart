import 'package:flutter/material.dart';

class AppColors {
  // Primary colors with WCAG AA compliant contrast ratios
  static const Color primary = Color(
    0xFF1D4ED8,
  ); // Darker Blue 600 for better contrast
  static const Color primaryDark = Color(
    0xFF60A5FA,
  ); // Lighter Blue 400 for dark mode

  // Text colors with WCAG AAA compliant contrast ratios
  static const Color lightTextPrimary = Color(0xDE000000); // 87% black
  static const Color lightTextSecondary = Color(
    0xB3000000,
  ); // 70% black for better contrast
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // 100% white
  static const Color darkTextSecondary = Color(
    0xE6FFFFFF,
  ); // 90% white for better contrast

  // Background colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);

  // Success colors with WCAG AA compliant contrast ratios
  static const Color success = Color(0xFF047857); // Darker Green 700
  static const Color successDark = Color(0xFF34D399); // Lighter Green 400

  // Error colors with WCAG AA compliant contrast ratios
  static const Color error = Color(
    0xFFB91C1C,
  ); // Darker Red 700 for better contrast
  static const Color errorDark = Color(
    0xFFF87171,
  ); // Lighter Red 400 for dark mode

  // Surface colors
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF242424);

  // Standard semantic colors
  static const Color incomeGreen = Color(0xFF059669); // Green 600
  static const Color incomeGreenDark = Color(0xFF10B981); // Green 500
  static const Color expenseRed = Color(0xFFDC2626); // Red 600
  static const Color expenseRedDark = Color(0xFFEF4444); // Red 500
  static const Color warningOrange = Color(0xFFF97316); // Orange 500
  static const Color warningOrangeDark = Color(0xFFFF9800); // Orange 400

  // Gray scale
  static const Color gray = Color(0xFF6B7280); // Gray 500
  static const Color grayLight = Color(0xFF9CA3AF); // Gray 400
  static const Color grayDark = Color(0xFF4B5563); // Gray 600

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Helper method to get theme-aware income color
  static Color getIncomeColor(bool isDark) {
    return isDark ? incomeGreenDark : incomeGreen;
  }

  // Helper method to get theme-aware expense color
  static Color getExpenseColor(bool isDark) {
    return isDark ? expenseRedDark : expenseRed;
  }

  // Helper method to get theme-aware gray color
  static Color getGrayColor(bool isDark) {
    return isDark ? grayLight : gray;
  }
}
