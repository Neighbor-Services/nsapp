import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/rate.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/seeker/data/datasource/remote/seeker_remote_datasource.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/core/models/appointment.dart';

class SeekerRemoteDatasourceImpl extends SeekerRemoteDatasource {
  @override
  Future<bool> createRequest(Request request) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseRequestUrl/services/requests/",
        data: request.toJson(),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201) {
        if (request.withImage!) {
          final id =
              response.data["id"] ??
              (response.data["request"] != null
                  ? response.data["request"]["id"]
                  : null);

          final res = await dio.patch(
            "$baseUrl/services/requests/image/",
            data: FormData.fromMap({
              "data": json.encode({"id": id}),
              "image": await MultipartFile.fromFile(image!.path),
            }),
            options: Options(headers: dioMultiPartHeaders(token)),
          );

          if (res.statusCode == 200) {
            return true;
          } else {
            return true;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          debugPrint("CREATE REQUEST ERROR BODY: ${e.response?.data}");
        }
      }
      debugPrint("CREATE REQUEST ERROR: $e");
      return false;
    }
  }

  @override
  Future<List<RequestData>?> myRequest() async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseRequestUrl/services/requests/?user_me=true",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        List<RequestData> requests = [];
        var data = (response.data is List)
            ? response.data
            : (response.data is Map
                  ? response.data["results"]
                  : []); // robust parsing

        if (data != null) {
          for (var request in data) {
            if (request is Map<String, dynamic>) {
              requests.add(RequestData.fromJson(request));
            }
          }
        }
        return requests;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Profile>?> getPopularProviders() async {
    final token = await Helpers.getString("token");
    try {
      final response = dio
          .get(
            "$baseUrl/accounts/profile/?user_type=PROVIDER&popular=true",
            options: Options(headers: dioHeaders(token)),
          )
          .asStream();
      final data = await response.last;
      if (data.statusCode == 200) {
        List<Profile> providers = [];
        // Accounts might use 'providers' key or results. Checking standardized approach.
        var list = (data.data is List)
            ? data.data
            : (data.data is Map
                  ? (data.data["results"] ?? data.data["providers"])
                  : []);

        if (list != null) {
          for (var profile in list) {
            if (profile is Map<String, dynamic>) {
              providers.add(Profile.fromJson(profile));
            }
          }
        }
        return providers;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<RequestAcceptance>?> getAcceptedUsers({
    required String request,
  }) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseRequestUrl/services/proposals/?service_request=$request",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        List<RequestAcceptance> providers = [];
        var data = (response.data is List)
            ? response.data
            : (response.data is Map
                  ? (response.data["results"] ??
                        response.data["requests_acceptance"])
                  : []);

        if (data != null) {
          for (var profile in data) {
            if (profile is Map<String, dynamic>) {
              providers.add(RequestAcceptance.fromJson(profile));
            }
          }
        }
        return providers;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> approveRequest({
    required String user,
    required String serviceRequestId,
    required String proposalId,
  }) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseRequestUrl/services/requests/$serviceRequestId/approve_proposal/",
        options: Options(headers: dioHeaders(token)),
        data: {"proposal_id": proposalId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<RequestData?> reloadRequest({required String request}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseRequestUrl/services/requests/$request/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        // Standard Detail View returns the object directly
        return RequestData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> cancelApproveRequest({required String requestId}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseRequestUrl/services/requests/$requestId/cancel_approval/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteRequest({required String requestId}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.delete(
        "$baseRequestUrl/services/requests/$requestId/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateRequest({required Request request}) async {
    try {
      final token = await Helpers.getString("token");
      final updateData = request.toUpdateJson();
      debugPrint(
        "UPDATE REQUEST ATTEMPT - URL: $baseRequestUrl/services/requests/${request.id}/",
      );
      debugPrint("UPDATE REQUEST ATTEMPT - DATA: ${json.encode(updateData)}");

      final response = await dio.patch(
        "$baseRequestUrl/services/requests/${request.id}/",
        data: updateData,
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        if (request.withImage! && image != null) {
          final res = await dio.patch(
            "$baseUrl/services/requests/image/",
            data: FormData.fromMap({
              "data": json.encode({"id": request.id}),
              "image": await MultipartFile.fromFile(image!.path),
            }),
            options: Options(headers: dioMultiPartHeaders(token)),
          );
          if (res.statusCode == 200) {
            return true;
          } else {
            return true;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          debugPrint("UPDATE REQUEST ERROR BODY: ${e.response?.data}");
        }
      }
      debugPrint("UPDATE REQUEST ERROR: $e");
      return false;
    }
  }

  @override
  Future<bool> addToFavorite({required String uid}) async {
    final token = await Helpers.getString("token");

    try {
      final response = await dio.post(
        "$baseUrl/interactions/favorites/",
        data: {"provider": uid},
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
  Future<bool> removeFromFavorite({required String id}) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.delete(
        "$baseUrl/interactions/favorites/$id/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Favorite>?> getMyFavorites() async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/interactions/favorites/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        List<Favorite> providers = [];
        // Standardized parsing
        var data = (response.data is List)
            ? response.data
            : (response.data is Map ? response.data["results"] : []);

        if (data != null) {
          for (var profile in data) {
            if (profile is Map<String, dynamic>) {
              providers.add(Favorite.fromJson(profile));
            }
          }
        }
        return providers;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AppointmentData>?> getAppointment() async {
    try {
      final token = await Helpers.getString("token");

      final response = dio.get(
        "$baseUrl/interactions/appointments/",
        options: Options(headers: dioHeaders(token)),
      );
      final data = await response;
      if (data.statusCode == 200) {
        List<AppointmentData> requests = [];
        // Standardized parsing
        var list = (data.data is List)
            ? data.data
            : (data.data is Map ? data.data["results"] : []);

        if (list != null) {
          for (var appointment in list) {
            if (appointment is Map<String, dynamic>) {
              requests.add(AppointmentData.fromJson(appointment));
            }
          }
        }
        return requests;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Profile>?> searchProviders({
    double? ratingMin,
    double? priceMin,
    double? priceMax,
    String? categoryName,
    String? serviceName,
    String? city,
  }) async {
    final token = await Helpers.getString("token");
    try {
      String queryString = "user_type=PROVIDER";
      if (ratingMin != null) queryString += "&rating_min=$ratingMin";
      if (priceMin != null) queryString += "&price_min=$priceMin";
      if (priceMax != null) queryString += "&price_max=$priceMax";
      if (categoryName != null) queryString += "&category_name=$categoryName";
      if (serviceName != null) queryString += "&service_name=$serviceName";
      if (city != null) queryString += "&city=$city";

      final response = await dio.get(
        "$baseUrl/accounts/profile/?$queryString",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        List<Profile> providers = [];
        var data = (response.data is List)
            ? response.data
            : (response.data is Map
                  ? (response.data["results"] ?? response.data["providers"])
                  : []);

        if (data != null) {
          for (var profile in data) {
            if (profile is Map<String, dynamic>) {
              providers.add(Profile.fromJson(profile));
            }
          }
        }
        return providers;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> markAsDone({required Request request}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.patch(
        "$baseRequestUrl/services/requests/${request.id}/",
        options: Options(headers: dioHeaders(token)),
        data: {"status": "DONE"}, // Changed COMPLETED to DONE to match statuses
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> rate(Rate rate) async {
    final token = await Helpers.getString("token");
    try {
      // data removed as it was unused and duplicate of post body logic
      final response = await dio.post(
        "$baseUrl/interactions/reviews/",
        data: {
          "rating": rate.rate,
          "provider": rate.id,
          "comment": "Rated via app",
        },
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Successfully rated ${ProviderToReviewState.profile.firstName}",
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> cancelAppointment({required String id}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.delete(
        "$baseUrl/interactions/appointments/$id/",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateAppointment({required Appointment appointment}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.patch(
        "$baseUrl/interactions/appointments/${appointment.id}/",
        data: appointment.toJson(),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> completeAppointment({
    required String id,
    required double amount,
  }) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/interactions/appointments/$id/complete/",
        data: {"amount": amount},
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<List<Profile>?> matchProviders({required String description}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseRequestUrl/services/match-providers/",
        data: {"description": description},
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        List<Profile> providers = [];
        var data = (response.data is List)
            ? response.data
            : (response.data is Map ? response.data["results"] : []); // robust
        if (data != null) {
          for (var profileJson in data) {
            providers.add(Profile.fromJson(profileJson));
          }
        }
        return providers;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
