import 'package:flutter/material.dart';

class ValidationConstants {
  static final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static const passwordMinLength = 8;
  static const passwordRequirements = [
    'At least 8 characters',
    'At least one uppercase letter',
    'At least one lowercase letter',
    'At least one number',
  ];

  static String getPasswordStrength(String password) {
    if (password.isEmpty) return 'None';
    if (password.length < 8) return 'Weak';
    if (!passwordRegex.hasMatch(password)) return 'Medium';
    return 'Strong';
  }

  static Color getPasswordStrengthColor(String strength) {
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static MaterialColor getStepperColor(int currentStep, int step) {
    if (step < currentStep) return Colors.green;
    if (step == currentStep) return Colors.blue;
    return Colors.grey;
  }

  static double getStrengthProgress(String strength) => switch (strength) {
    'Weak' => 0.33,
    'Medium' => 0.66,
    'Strong' => 1.0,
    _ => 0.0,
  };

  static bool isPasswordRequirementMet(String password, String requirement) =>
      password.isNotEmpty &&
      switch (requirement) {
        'At least 8 characters' => password.length >= passwordMinLength,
        'At least one uppercase letter' => RegExp(r'[A-Z]').hasMatch(password),
        'At least one lowercase letter' => RegExp(r'[a-z]').hasMatch(password),
        'At least one number' => RegExp(r'[0-9]').hasMatch(password),
        _ => false,
      };
}
