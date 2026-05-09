import 'package:flutter/material.dart';

class SettingsState {
  final bool isProvider;
  final ThemeMode themeMode;
  final bool useBiometric;

  SettingsState({
    required this.isProvider,
    required this.themeMode,
    required this.useBiometric,
  });

  SettingsState copyWith({
    bool? isProvider,
    ThemeMode? themeMode,
    bool? useBiometric,
  }) {
    return SettingsState(
      isProvider: isProvider ?? this.isProvider,
      themeMode: themeMode ?? this.themeMode,
      useBiometric: useBiometric ?? this.useBiometric,
    );
  }
}

/// Emitted when a settings operation is in progress.
class LoadingSettingsState extends SettingsState {
  LoadingSettingsState(SettingsState from)
      : super(
          isProvider: from.isProvider,
          themeMode: from.themeMode,
          useBiometric: from.useBiometric,
        );
}

/// Emitted when a user-type change completes successfully.
class SuccessChangeUserTypeState extends SettingsState {
  SuccessChangeUserTypeState(SettingsState from)
      : super(
          isProvider: from.isProvider,
          themeMode: from.themeMode,
          useBiometric: from.useBiometric,
        );
}

/// Emitted when any settings operation fails.
class SettingsFailure extends SettingsState {
  final String message;
  SettingsFailure(this.message, SettingsState from)
      : super(
          isProvider: from.isProvider,
          themeMode: from.themeMode,
          useBiometric: from.useBiometric,
        );
}

/// Aliases kept for backward-compat with pages that still check subclasses.
typedef SettingsLoadedState = SettingsState;
typedef SettingsLoadingState = SettingsState;
typedef SettingsLoading = SettingsState;

/// Emitted when a report is added successfully.
class SuccessAddReportState extends SettingsState {
  SuccessAddReportState(SettingsState from)
      : super(
          isProvider: from.isProvider,
          themeMode: from.themeMode,
          useBiometric: from.useBiometric,
        );
}

/// Emitted when adding a report fails.
class FailureAddReportState extends SettingsState {
  final String message;
  FailureAddReportState(this.message, SettingsState from)
      : super(
          isProvider: from.isProvider,
          themeMode: from.themeMode,
          useBiometric: from.useBiometric,
        );
}
