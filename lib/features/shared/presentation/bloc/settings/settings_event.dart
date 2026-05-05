import 'package:flutter/material.dart';

abstract class SettingsEvent {}

class ToggleDashboardEvent extends SettingsEvent {
  final bool isProvider;
  ToggleDashboardEvent({required this.isProvider});
}

class ToggleThemeModeEvent extends SettingsEvent {
  final ThemeMode themeMode;
  ToggleThemeModeEvent({required this.themeMode});
}

class LoadThemeModeEvent extends SettingsEvent {}

class UseBiometricEvent extends SettingsEvent {
  final bool useBiometric;
  UseBiometricEvent({required this.useBiometric});
}

class ChangeUserTypeEvent extends SettingsEvent {
  final Map<String, String> type;
  ChangeUserTypeEvent(this.type);
}

class AddReportEvent extends SettingsEvent {
  final dynamic report;
  AddReportEvent({required this.report});
}
