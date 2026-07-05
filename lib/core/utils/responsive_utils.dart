import 'package:flutter/material.dart';

/// Responsive utility helpers.
///
/// Provides convenient access to screen dimensions and breakpoints.
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Returns the screen width.
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Returns the screen height.
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Returns true if the screen is a compact (phone) size.
  static bool isCompact(BuildContext context) =>
      screenWidth(context) < 600;

  /// Returns true if the screen is a medium (tablet) size.
  static bool isMedium(BuildContext context) =>
      screenWidth(context) >= 600 && screenWidth(context) < 840;

  /// Returns true if the screen is an expanded (desktop) size.
  static bool isExpanded(BuildContext context) =>
      screenWidth(context) >= 840;

  /// Returns horizontal padding based on screen size.
  static double horizontalPadding(BuildContext context) {
    if (isExpanded(context)) return 32.0;
    if (isMedium(context)) return 24.0;
    return 20.0;
  }
}
