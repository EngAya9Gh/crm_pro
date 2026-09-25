import 'package:flutter/material.dart';

class ResponsiveHelper {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    if (screenWidth == 0) screenWidth = 375; // fallback for tests or splash
    if (screenHeight == 0) screenHeight = 812;
    _blockSizeHorizontal = screenWidth / 100;
    _blockSizeVertical = screenHeight / 100;
  }

  // Get responsive font size
  static double sp(double fontSize) {
    if (screenWidth == 0) return fontSize; // fallback
    double scale = screenWidth / 360;
    return fontSize * scale;
  }

  // Get responsive width
  static double w(double width) {
    return width * (screenWidth / 375);
  }

  // Get responsive height
  static double h(double height) {
    return height * (screenHeight / 812);
  }

  static bool isTablet() => screenWidth >= 600;
  static bool isDesktop() => screenWidth >= 1200;
}

// Extension to make it easier to use
extension ResponsiveExtension on num {
  double get sp => ResponsiveHelper.sp(toDouble());
  double get w => ResponsiveHelper.w(toDouble());
  double get h => ResponsiveHelper.h(toDouble());
}
