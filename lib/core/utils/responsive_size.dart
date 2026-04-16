import 'package:flutter/widgets.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static double? _scaleWidth;
  static double? _scaleHeight;
  static double? _scaleText;

  // Base design size (iPhone 13/14)
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    
    _blockSizeHorizontal = screenWidth / 100;
    _blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    _scaleWidth = screenWidth / _designWidth;
    _scaleHeight = screenHeight / _designHeight;
    // Use the smaller scale for text to prevent extreme scaling
    _scaleText = _scaleWidth! < _scaleHeight! ? _scaleWidth : _scaleHeight;
  }

  static double get wScale => _scaleWidth ?? 1.0;
  static double get hScale => _scaleHeight ?? 1.0;
  static double get textScale => _scaleText ?? 1.0;
}

extension ResponsiveSizeExtension on num {
  /// Responsive Width
  double get w => this * 0.90; // Responsive.wScale;

  /// Responsive Height
  double get h => this * 0.90; // Responsive.hScale;

  /// Responsive Font Size
  double get sp => this * 0.90; // Responsive.textScale;

  /// Responsive Radius
  double get r => this * 0.90; // (Responsive.wScale < Responsive.hScale ? Responsive.wScale : Responsive.hScale);
}
