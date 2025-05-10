import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final textColor =
        isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textColorSecondary =
        isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
    final backgroundColor =
        isLight ? AppColors.lightBackground : AppColors.darkBackground;
    final surfaceColor =
        isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final primaryColor = isLight ? AppColors.primary : AppColors.primaryDark;

    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,

      // Configure text theme with accessibility in mind
      textTheme: TextTheme(
        // Large text (≥18sp) needs contrast ratio ≥3:1
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32.sp,
          height: 1.3,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28.sp,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),

        // Body text with high contrast
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.sp,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.sp,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.sp,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color:
              textColorSecondary, // Using higher contrast secondary color for small text
        ),

        // Titles with proper contrast
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20.sp,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18.sp,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.sp,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),

        // Labels with enhanced contrast
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.sp,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.sp,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: textColor, // Using primary text color for better contrast
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.sp,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: textColor, // Using primary text color for better contrast
        ),
      ),

      // Configure color scheme with accessible colors
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isLight ? Colors.white : Colors.black,
        secondary: isLight ? AppColors.success : AppColors.successDark,
        onSecondary: isLight ? Colors.white : Colors.black,
        error: isLight ? AppColors.error : AppColors.errorDark,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textColor,
        surface: surfaceColor,
        onSurface: textColor,
      ),

      // Configure switches with accessible colors
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return isLight ? AppColors.primary : AppColors.primaryDark;
          }
          return isLight ? Colors.grey[400] : Colors.grey[600];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return isLight
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.primaryDark.withOpacity(0.5);
          }
          return isLight ? Colors.grey[300] : Colors.grey[700];
        }),
      ),

      // Configure elevated buttons with accessible colors
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isLight ? Colors.white : Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20.sp,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
