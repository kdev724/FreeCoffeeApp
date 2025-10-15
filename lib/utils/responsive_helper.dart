import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate scale factor based on screen size
    double scaleFactor =
        (screenWidth + screenHeight) / (375 + 812); // iPhone X as baseline
    scaleFactor = scaleFactor.clamp(0.8, 1.4); // Limit scale factor

    return baseSize * scaleFactor;
  }

  static double getResponsivePadding(BuildContext context, double basePadding) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375; // iPhone X width as baseline
    scaleFactor = scaleFactor.clamp(0.7, 1.3); // Limit scale factor

    return basePadding * scaleFactor;
  }

  static double getResponsiveRadius(BuildContext context, double baseRadius) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375; // iPhone X width as baseline
    scaleFactor = scaleFactor.clamp(0.8, 1.2); // Limit scale factor

    return baseRadius * scaleFactor;
  }

  static EdgeInsets getResponsiveEdgeInsets(
    BuildContext context, {
    double horizontal = 24.0,
    double vertical = 24.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: getResponsivePadding(context, horizontal),
      vertical: getResponsivePadding(context, vertical),
    );
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375; // iPhone X width as baseline
    scaleFactor = scaleFactor.clamp(0.8, 1.2); // Limit scale factor

    return baseSize * scaleFactor;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 400;
  }

  static bool isMediumScreen(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= 400 && width < 800;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}
