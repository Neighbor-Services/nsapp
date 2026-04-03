import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/services/google_sign_in_service.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/features/authentications/data/datasource/remote/authentication_remote_data_source.dart';

class AuthenticationRemoteDataSourceImpl
    extends AuthenticationRemoteDataSource {
  @override
  Future<bool> register(String email, String password) async {
    try {
      Map<String, dynamic> data = {"email": email, "password": password};
      final response = await dio.post(
        "$baseUrl/accounts/register/",
        data: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        await Helpers.saveString("email", email);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool?> login(String email, String password) async {
    try {
      Map<String, dynamic> data = {"email": email, "password": password};

      final response = await dio.post(
        "$baseUrl/accounts/login/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final token = response.data;

        final success = await Helpers.saveString("token", token["access"]);
        if (success) {
          return true;
        }
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {
          final response = e.response;
          if (response != null && response.data != null) {
            final data = response.data;
            if (data is Map) {
              // Handle common DRF error formats
              if (data.containsKey('non_field_errors')) {
                throw data['non_field_errors'][0];
              } else if (data.containsKey('detail')) {
                throw data['detail'];
              } else if (data.containsKey('error')) {
                throw data['error'];
              }
            } else if (data is List && data.isNotEmpty) {
              throw data[0].toString();
            }
          }
        }
      }
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final deleted = await Helpers.deletePref("token");
      if (deleted) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword(String otp, String password) async {
    try {
      final email = await Helpers.getString("email");

      Map<String, dynamic> data = {
        "email": email,
        "otp_code": otp,
        "new_password": password,
      };
      final response = await dio.post(
        "$baseUrl/accounts/password-reset-otp-confirm/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {}
      }
      return false;
    }
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    try {
      await Helpers.saveString("email", email);
      Map<String, dynamic> data = {"email": email};
      final response = await dio.post(
        "$baseUrl/accounts/password-reset/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {}
      }
      return false;
    }
  }

  @override
  @override
  Future<bool> loginWithGoogle() async {
    try {
      final googleService = GoogleSignInService(
        
      );
      final googleUser = await googleService.signIn();

      if (googleUser == null) return false; // User canceled

      final googleAuth = await googleService.getAuthentication(googleUser);
      final String? idToken = googleAuth?.idToken;

      if (idToken == null) return false;

      Map<String, dynamic> data = {"id_token": idToken};

      final response = await dio.post(
        "$baseUrl/accounts/login-google/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final token = response.data;

        await Helpers.saveString("email", googleUser.email);
        final success = await Helpers.saveString(
          "token",
          token["access"], // Access token from backend
        );
        if (success) {
          return true;
        }
      }
      return false;
    } catch (error) {
      debugPrint("Google Login Error: $error");
      return false;
    }
  }

  @override
  Future<bool> registerWithGoogle() async {
    // Register flow is now same as login flow (upsert)
    return loginWithGoogle();
  }

  @override
  Future<bool> verifyRegistration(String otp) async {
    try {
      final email = await Helpers.getString("email");

      if (email != "") {
        Map<String, dynamic> data = {"email": email, "otp_code": otp};
        final response = await dio.post(
          "$baseUrl/accounts/verify-otp/",
          data: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> changePassword(String oldPassword, String nwPassword) async {
    try {
      final token = await Helpers.getString("token");

      Map<String, dynamic> data = {
        "old_password": oldPassword,
        "new_password": nwPassword,
      };
      final response = await dio.put(
        "$baseUrl/accounts/change-password/",
        options: Options(headers: dioHeaders(token)),
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {}
      }
      return false;
    }
  }

  @override
  Future<bool> verifyEmail(String otp) async {
    try {
      final email = await Helpers.getString("email");
      Map<String, dynamic> data = {"email": email, "otp_code": otp};
      final response = await dio.post(
        "$baseUrl/accounts/verify-otp/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {}
      }
      return false;
    }
  }

  @override
  Future<bool> sendEmailVerification(String email) async {
    try {
      await Helpers.saveString("email", email);
      Map<String, dynamic> data = {"email": email};
      final response = await dio.post(
        "$baseUrl/accounts/resend-otp/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {}
      }
      return false;
    }
  }

  @override
  Future<bool> loginWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // TODO: Replace with your actual Service ID (clientId) later
          clientId: 'com.neighborservicesolutionsllc.nsapp.service',
          redirectUri: Uri.parse(
            'https://api.neighborservice.com/callbacks/apple',
          ),
        ),
      );

      final String? idToken = credential.identityToken;

      if (idToken == null) return false;

      Map<String, dynamic> data = {
        "id_token": idToken,
        "first_name": credential.givenName ?? "",
        "last_name": credential.familyName ?? ""
      };

      final response = await dio.post(
        "$baseUrl/accounts/login-apple/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final token = response.data;
        if (credential.email != null) {
          await Helpers.saveString("email", credential.email!);
        }
        final success = await Helpers.saveString(
          "token",
          token["access"], 
        );
        if (success) {
          return true;
        }
      }
      return false;
    } catch (error) {
      debugPrint("Apple Login Error: $error");
      return false;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.delete(
        "$baseUrl/accounts/delete-account/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        await Helpers.deletePref("token");
        await Helpers.deletePref("email");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Delete Account Error: $e");
      return false;
    }
  }
}
