import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

ThemeData providerLightTheme = ThemeData(
  primaryColor: appBlueCardColor,
  secondaryHeaderColor: appDeepBlueColor1,
  primaryColorLight: appDeepBlueColor1,
  brightness: Brightness.light,
  textTheme: lightTextTheme,
  scaffoldBackgroundColor: appBackgroundColor,
);

ThemeData seekerLightTheme = ThemeData(
  primaryColor: appOrangeColor1,
  secondaryHeaderColor: appOrangeColor2,
  primaryColorLight: appLightBlueCard,
  brightness: Brightness.dark,
  textTheme: lightTextTheme,
  scaffoldBackgroundColor: appBackgroundColor,
);
