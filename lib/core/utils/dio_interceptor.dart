import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/di/injection_container.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';

class GlobalDioInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      debugPrint("DEBUG [GlobalDioInterceptor]: 401 Unauthorized detected. Dispatching Logout.");
      try {
        sl<AuthenticationBloc>().add(LogoutAuthenticationEvent());
      } catch (e) {
        debugPrint("DEBUG [GlobalDioInterceptor]: Error dispatching Logout: $e");
      }
    }
    super.onError(err, handler);
  }
}
