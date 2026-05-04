import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/di/injection_container.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/authentications/data/datasource/remote/authentication_remote_data_source.dart';
import 'package:nsapp/core/constants/urls.dart';

class GlobalDioInterceptor extends Interceptor {
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      debugPrint("DEBUG [GlobalDioInterceptor]: 401 Unauthorized detected. Attempting Refresh.");
      
      try {
        final authDataSource = sl<AuthenticationRemoteDataSource>();
        final newToken = await authDataSource.refreshToken();
        
        if (newToken != null) {
          debugPrint("DEBUG [GlobalDioInterceptor]: Token Refreshed. Retrying original request.");
          
          final requestOptions = err.requestOptions;
          requestOptions.headers.addAll(dioHeaders(newToken));
          
          final response = await sl<Dio>().fetch(requestOptions);
          return handler.resolve(response);
        } else {
          debugPrint("DEBUG [GlobalDioInterceptor]: Refresh failed. Dispatching Logout.");
          sl<AuthenticationBloc>().add(LogoutAuthenticationEvent());
        }
      } catch (e) {
        debugPrint("DEBUG [GlobalDioInterceptor]: Error during refresh flow: $e. Dispatching Logout.");
        sl<AuthenticationBloc>().add(LogoutAuthenticationEvent());
      }
    }
    return super.onError(err, handler);
  }
}
