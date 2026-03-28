import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color surfaceBackground;
  final Color cardBackground;
  final Color appBarBackground;
  final Color glassBackground;
  final Color glassBorder;
  final Color iconContainerBackground;
  final Color iconColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color hintTextColor;
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final Color primaryColor;
  final Color secondaryColor;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;
  final Color infoColor;

  const AppColorsExtension({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.surfaceBackground,
    required this.cardBackground,
    required this.appBarBackground,
    required this.glassBackground,
    required this.glassBorder,
    required this.iconContainerBackground,
    required this.iconColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.hintTextColor,
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.primaryColor,
    required this.secondaryColor,
    required this.successColor,
    required this.errorColor,
    required this.warningColor,
    required this.infoColor,
  });

  @override
  AppColorsExtension copyWith({
    Color? primaryBackground,
    Color? secondaryBackground,
    Color? surfaceBackground,
    Color? cardBackground,
    Color? appBarBackground,
    Color? glassBackground,
    Color? glassBorder,
    Color? iconContainerBackground,
    Color? iconColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? hintTextColor,
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    Color? primaryColor,
    Color? secondaryColor,
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
    Color? infoColor,
  }) {
    return AppColorsExtension(
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      surfaceBackground: surfaceBackground ?? this.surfaceBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      iconContainerBackground: iconContainerBackground ?? this.iconContainerBackground,
      iconColor: iconColor ?? this.iconColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      hintTextColor: hintTextColor ?? this.hintTextColor,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primaryBackground: Color.lerp(primaryBackground, other.primaryBackground, t)!,
      secondaryBackground: Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      surfaceBackground: Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      appBarBackground: Color.lerp(appBarBackground, other.appBarBackground, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      iconContainerBackground: Color.lerp(iconContainerBackground, other.iconContainerBackground, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
      secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
      hintTextColor: Color.lerp(hintTextColor, other.hintTextColor, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      secondaryGradient: LinearGradient.lerp(secondaryGradient, other.secondaryGradient, t)!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
    );
  }
}

extension AppThemeExtension on BuildContext {
  AppColorsExtension get appColors => Theme.of(this).extension<AppColorsExtension>()!;
}
