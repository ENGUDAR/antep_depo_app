import 'package:flutter/material.dart';

class ScreenUtil {
  static final ScreenUtil _instance = ScreenUtil._internal();

  double? screenWidth;
  double? screenHeight;

  // Private constructor for singleton pattern
  ScreenUtil._internal();

  // Factory constructor to return the same instance
  factory ScreenUtil() {
    return _instance;
  }

  // Ekran boyutlarını hesaplayan fonksiyon
  void init(BuildContext context) {
    if (screenWidth == null || screenHeight == null) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
    }
  }

  // En küçük boyutu (width veya height) döndüren fonksiyon
  double getSmallestDimension() {
    if (screenWidth != null && screenHeight != null) {
      return screenWidth! < screenHeight! ? screenWidth! : screenHeight!;
    } else {
      throw Exception("ScreenUtil is not initialized. Please call init() first.");
    }
  }
}
