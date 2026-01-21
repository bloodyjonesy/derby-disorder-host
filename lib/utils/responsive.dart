import 'package:flutter/material.dart';

/// Responsive utilities for scaling UI across different screen sizes
class Responsive {
  /// Reference design dimensions (1920x1080 - standard TV)
  static const double referenceWidth = 1920;
  static const double referenceHeight = 1080;

  /// Get scale factor based on screen width
  static double scaleWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / referenceWidth).clamp(0.5, 1.5);
  }

  /// Get scale factor based on screen height
  static double scaleHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight / referenceHeight).clamp(0.5, 1.5);
  }

  /// Get overall scale factor (minimum of width/height to ensure fit)
  static double scale(BuildContext context) {
    final scaleW = scaleWidth(context);
    final scaleH = scaleHeight(context);
    return (scaleW < scaleH ? scaleW : scaleH).clamp(0.5, 1.5);
  }

  /// Scale a dimension value responsively
  static double sp(BuildContext context, double value) {
    return value * scale(context);
  }

  /// Scale font size responsively
  static double fontSize(BuildContext context, double baseSize) {
    return (baseSize * scale(context)).clamp(8.0, baseSize * 1.2);
  }

  /// Scale padding/margin responsively
  static EdgeInsets padding(BuildContext context, EdgeInsets basePadding) {
    final s = scale(context);
    return EdgeInsets.only(
      left: basePadding.left * s,
      right: basePadding.right * s,
      top: basePadding.top * s,
      bottom: basePadding.bottom * s,
    );
  }

  /// Check if screen is considered "small" (tablet/phone)
  static bool isSmallScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 1280;
  }

  /// Check if screen is considered "very small" (phone)
  static bool isVerySmallScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 800;
  }
}

/// Extension for easy responsive scaling
extension ResponsiveExtension on num {
  /// Scale this number responsively based on screen size
  double scaled(BuildContext context) => Responsive.sp(context, toDouble());
  
  /// Scale this font size responsively
  double scaledFont(BuildContext context) => Responsive.fontSize(context, toDouble());
}
