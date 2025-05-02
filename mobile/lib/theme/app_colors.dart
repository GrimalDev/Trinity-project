import 'package:flutter/material.dart';

/// App color constants for consistent theming
class AppColors {
  // Base colors
  static const Color background = Colors.black;
  static final Color cardBackground = Colors.grey[900]!;
  static final Color sectionBackground = Colors.grey[850]!;
  static final Color borderColor = Colors.grey[800]!;

  // Text colors
  static const Color primaryText = Colors.white;
  static final Color secondaryText = Colors.grey[300]!;
  static final Color tertiaryText = Colors.grey[400]!;

  // Action colors
  static const Color primary = Colors.green;
  static const Color danger = Colors.red;

  // Prevent instantiation
  AppColors._();
}
