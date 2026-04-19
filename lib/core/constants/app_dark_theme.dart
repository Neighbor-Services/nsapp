import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

ThemeData providerDarkTheme = ThemeData(
  primaryColor: appMiddleBlueCard,
  secondaryHeaderColor: appShadowColor,
  primaryColorLight: appDeepBlueColor1,
  brightness: Brightness.dark,
  fontFamily: 'FuturaPT',
  textTheme: darkTextTheme,
  scaffoldBackgroundColor: const Color(0xFF13141A),
  extensions: [
    AppColorsExtension(
      primaryBackground: const Color(0xFF13141A),
      secondaryBackground: const Color(0xFF13141A),
      surfaceBackground: const Color(0xFF13141A),
      cardBackground: const Color(0xFF1D2129),
      appBarBackground: const Color(0xFF13141A),
      glassBackground: Colors.black.withValues(alpha: 30),
      glassBorder: const Color(0xFF2A2D35),
      iconContainerBackground: Colors.black.withValues(alpha: 30),
      iconColor: Colors.white,
      primaryTextColor: Colors.white,
      secondaryTextColor: const Color(0xFF5A5F72),
      hintTextColor: const Color(0xFF5A5F72),
      primaryGradient: const LinearGradient(
        colors: [Color(0xFF2A313D), Color(0xFF5E17EB)],
      ),
      secondaryGradient: const LinearGradient(
        colors: [Color(0xFF2A313D), Color(0xFF5A52D5)],
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

ThemeData seekerDarkTheme = providerDarkTheme.copyWith(
  primaryColor: appOrangeColor1,
  secondaryHeaderColor: appOrangeColor2,
  primaryColorLight: appLightBlueCard,
);
