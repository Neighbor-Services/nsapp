import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/features/shared/domain/usecase/change_user_type_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/add_report_use_case.dart';
export 'settings_event.dart';
export 'settings_state.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  final ChangeUserTypeUseCase changeUserTypeUseCase;
  final AddReportUseCase addReportUseCase;

  SettingsBloc({required this.changeUserTypeUseCase, required this.addReportUseCase})
      : super(SettingsState(
          isProvider: false,
          themeMode: ThemeMode.system,
          useBiometric: false,
        )) {
    on<ToggleDashboardEvent>((event, emit) {
      emit(state.copyWith(isProvider: event.isProvider));
    });

    on<ToggleThemeModeEvent>((event, emit) async {
      final isDark = event.themeMode == ThemeMode.dark;
      final isSuccess = await Helpers.saveBool("darkmode", isDark);
      if (isSuccess) {
        emit(state.copyWith(themeMode: event.themeMode));
      }
    });

    on<LoadThemeModeEvent>((event, emit) async {
      final prefsInstance = await prefs;
      final isDark = prefsInstance.getBool("darkmode");
      ThemeMode mode;
      if (isDark == true) {
        mode = ThemeMode.dark;
      } else if (isDark == false) {
        mode = ThemeMode.light;
      } else {
        mode = ThemeMode.system;
      }
      emit(state.copyWith(themeMode: mode));
    });

    on<UseBiometricEvent>((event, emit) async {
      final bool isSuccess =
          await Helpers.saveBool("usebiometric", event.useBiometric);
      if (isSuccess) {
        emit(state.copyWith(useBiometric: event.useBiometric));
      }
    });

    on<ChangeUserTypeEvent>((event, emit) async {
      final results = await changeUserTypeUseCase(event.type);
      results.fold(
        (l) => emit(SettingsFailure(l.message ?? 'Failed to change user type', state)),
        (r) => emit(SuccessChangeUserTypeState(state)),
      );
    });

    on<AddReportEvent>((event, emit) async {
      final results = await addReportUseCase(event.report);
      results.fold(
        (l) => emit(FailureAddReportState(l.message ?? 'Failed to send report', state)),
        (r) => emit(SuccessAddReportState(state)),
      );
    });
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      return SettingsState(
        isProvider: json['isProvider'] ?? false,
        themeMode: ThemeMode.values[json['themeMode'] ?? ThemeMode.system.index],
        useBiometric: json['useBiometric'] ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'isProvider': state.isProvider,
      'themeMode': state.themeMode.index,
      'useBiometric': state.useBiometric,
    };
  }
}
