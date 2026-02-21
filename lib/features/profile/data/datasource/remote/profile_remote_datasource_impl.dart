import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/about.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/review.dart';

import 'profile_remote_datasource.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<bool> addProfile(Profile profile) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/accounts/profile/",
        data: json.encode(profile.toJson()),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (image != null) {
          final res = await dio.patch(
            "$baseUrl/accounts/profile/picture/",
            data: FormData.fromMap({
              "image": await MultipartFile.fromFile(image!.path),
            }),
            options: Options(headers: dioMultiPartHeaders(token)),
          );

          if (res.statusCode == 200) {
            return true;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {
          debugPrint("ADD PROFILE ERROR RESPONSE: ${e.response?.data}");
          debugPrint("ADD PROFILE ERROR STATUS: ${e.response?.statusCode}");
        } else {
          debugPrint("ADD PROFILE ERROR: ${e.message}");
        }
      } else {
        debugPrint("ADD PROFILE UNKNOWN ERROR: $e");
      }
      return false;
    }
  }

  @override
  Future<bool> updateProfile(Profile profile) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.patch(
        "$baseUrl/accounts/profile/update_me/",
        options: Options(headers: dioHeaders(token)),
        data: json.encode(profile.toJson()),
      );
      if (response.statusCode == 200) {
        if (image != null) {
          final res = await dio.patch(
            "$baseUrl/accounts/profile/picture/",
            data: FormData.fromMap({
              "image": await MultipartFile.fromFile(image!.path),
            }),
            options: Options(headers: dioMultiPartHeaders(token)),
          );

          if (res.statusCode == 200) {
            return true;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {
          debugPrint("UPDATE PROFILE ERROR RESPONSE: ${e.response?.data}");
          debugPrint("UPDATE PROFILE ERROR STATUS: ${e.response?.statusCode}");
        } else {
          debugPrint("UPDATE PROFILE ERROR: ${e.message}");
        }
      } else {
        debugPrint("UPDATE PROFILE UNKNOWN ERROR: $e");
      }
      return false;
    }
  }

  @override
  Future<bool> deleteProfile(String id) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Profile>> getProfiles() async {
    try {
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Profile?> getProfile(String id) async {
    if (id.isEmpty || id == "user!.uid") {
      debugPrint("INVALID PROFILE ID: $id");
      return null;
    }
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/accounts/profile/?user=$id",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        if (response.data["providers"] is List &&
            (response.data["providers"] as List).isNotEmpty) {
          return Profile.fromJson(response.data["providers"][0]);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Profile?> getProfileStream() async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/accounts/profile/me/",
        options: Options(headers: dioHeaders(token)),
      );

      final data = response;

      if (data.statusCode == 200) {
        return Profile.fromJson(
          Map<String, dynamic>.from(data.data["profile"]),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> addAbout(About about) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/accounts/about/",
        data: json.encode(about.toJson()),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AboutData?> getAboutStream(String userId) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/accounts/about/user/?user_id=$userId",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        return AboutData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {}

      return null;
    }
  }

  @override
  Future<bool> addReview(Review review) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.post(
        "$baseUrl/interactions/reviews/",
        data: json.encode(review.toJson()),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ReviewData>?> getReviews(String user) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/interactions/reviews/?provider=$user",
        options: Options(headers: dioHeaders(token)),
      );
      final data = response;
      if (data.statusCode == 200) {
        List<ReviewData> reviews = [];

        // Handle both standard list and paginated results
        var items = [];
        if (response.data is List) {
          items = response.data;
        } else if (response.data is Map && response.data["results"] is List) {
          items = response.data["results"];
        } else if (response.data is Map &&
            response.data["provider_reviews"] is List) {
          // Fallback for previous expected key
          items = response.data["provider_reviews"];
        }

        for (var item in items) {
          // Map backend serializer fields to ReviewData expectation
          // Backend ReviewSerializer returns reviewer_profile and provider_profile
          reviews.add(
            ReviewData(
              review: Review.fromJson(item),
              from: item["reviewer_profile"] != null
                  ? Profile.fromJson(item["reviewer_profile"])
                  : null,
              to: item["provider_profile"] != null
                  ? Profile.fromJson(item["provider_profile"])
                  : null,
            ),
          );
        }
        return reviews;
      }
      return null;
    } catch (e) {
      debugPrint("GET REVIEWS ERROR: $e");
      return null;
    }
  }

  @override
  Future<bool> updateDeviceToken() async {
    try {
      final String deviceToken = await Helpers.getToken();
      final token = await Helpers.getString("token");
      Map<String, dynamic> data = {"token": deviceToken};
      final response = await dio.patch(
        "$baseUrl/accounts/profile/update_me/",
        options: Options(headers: dioHeaders(token)),
        data: json.encode(data),
      );
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteAboutStream(String id) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.delete(
        "$baseUrl/accounts/about/$id/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {}

      return false;
    }
  }
}
