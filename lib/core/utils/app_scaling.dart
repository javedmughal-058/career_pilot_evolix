import 'dart:ui' as ui;

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class AppScale {
  const AppScale._();

  static const designWidth = 375.0;
  static const designHeight = 812.0;

  static Size get _screenSize {
    final context = globalNavigatorKey.currentState?.context;
    if (context != null) {
      return MediaQuery.sizeOf(context);
    }

    final views = ui.PlatformDispatcher.instance.views;
    if (views.isEmpty) return const Size(designWidth, designHeight);

    final view = views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  static double width(double value) {
    return _screenSize.width / (designWidth / value);
  }

  static double height(double value) {
    return _screenSize.height / (designHeight / value);
  }

  static double radius(double value) {
    final size = _screenSize;
    final scale = (size.width / designWidth + size.height / designHeight) / 2;
    return value * scale;
  }

  static double font(double value) {
    final scaled = width(value);
    return scaled.clamp(value * 0.88, value * 1.12).toDouble();
  }
}

extension ResponsiveDoubleExtension on double {
  double get h => AppScale.height(this);
  double get w => AppScale.width(this);
  double get r => AppScale.radius(this);
  double get sp => AppScale.font(this);
}

extension ResponsiveIntExtension on int {
  double get h => toDouble().h;
  double get w => toDouble().w;
  double get r => toDouble().r;
  double get sp => toDouble().sp;
}
