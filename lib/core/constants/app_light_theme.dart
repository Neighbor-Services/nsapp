import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

ThemeData providerLightTheme = ThemeData(
  primaryColor: appBlueCardColor,
  secondaryHeaderColor: appDeepBlueColor1,
  primaryColorLight: appDeepBlueColor1,
  brightness: Brightness.light,
  textTheme: lightTextTheme,
  scaffoldBackgroundColor: appBackgroundColor,
  extensions: [
    AppColorsExtension(
      primaryBackground: appBackgroundColor,
      secondaryBackground: const Color(0xFFF2F2F7),
      surfaceBackground: const Color(0xFFF2F2F7),
      cardBackground: const Color(0xFFFFFFFF),
      appBarBackground:const Color(0xFFF2F2F7),
      glassBackground: Colors.white.withValues(alpha: 60),
      glassBorder: const Color(0xFFE5E7EB),
      iconContainerBackground: Colors.white.withValues(alpha: 60),
      iconColor: Colors.black87,
      primaryTextColor: const Color(0xFF1E1E2E),
      secondaryTextColor: const Color(0xFF9CA3AF),
      hintTextColor: const Color(0xFF9CA3AF),
      primaryGradient: const LinearGradient(
        colors: [Color(0xFFFFFFFF), appBlueCardColor],
      ),
      secondaryGradient: const LinearGradient(
        colors: [Color(0xFFFFFFFF), appBlueCardColor],
      ),
      primaryColor: appDeepBlueColor1,
      secondaryColor: const Color(0xFF6C63FF),
      successColor: appSuccessColor,
      errorColor: appErrorColor,
      warningColor: appWarningColor,
      infoColor: appInfoColor,
    ),
  ],
);

ThemeData seekerLightTheme = providerLightTheme.copyWith(
  primaryColor: appOrangeColor1,
  secondaryHeaderColor: appOrangeColor2,
  primaryColorLight: appLightBlueCard,
);
