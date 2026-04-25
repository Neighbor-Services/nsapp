import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/data/datasource/remote/provider_remote_datasource.dart';


import '../../../../../core/constants/urls.dart';
import '../../../../../core/helpers/helpers.dart';

class ProviderRemoteDatasourceImpl extends ProviderRemoteDatasource {
  @override
  Future<bool> verifyAppointmentCode(String appointmentId, String code) async {
    final token = await Helpers.getString("token");
    final response = await dio.post(
      "$baseUrl/interactions/appointments/$appointmentId/verify_code/",
      data: {'code': code},
      options: Options(headers: dioHeaders(token)),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<List<RequestData>?> getRecentRequest({
    double? lat,
    double? lng,
    double? radius,
    int? page,
    bool? targeted,
    String? catalogServiceId,
  }) async {
    // Token fetched once — SharedPreferences read is synchronous after first load
    // but calling it N times in a session still adds up.
    final token = await Helpers.getString("token");
    try {
      String url = "$baseRequestUrl/services/requests/";
      Map<String, dynamic> params = {};
      if (lat != null) params['lat'] = lat;
      if (lng != null) params['lng'] = lng;
      if (radius != null) params['radius'] = radius;
      if (page != null) params['page'] = page;
      if (targeted != null) params['targeted'] = targeted.toString();
      if (catalogServiceId != null && catalogServiceId.isNotEmpty) {
        params['catalog_service'] = catalogServiceId;
        params['service'] = catalogServiceId;
      }

      final response = await dio.get(
        url,
        queryParameters: params,
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        List<RequestData> requests = [];
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey("results")) {
            data = response.data["results"];
          } else if (response.data.containsKey("requests")) {
            data = response.data["requests"];
          }
        }

        if (data.isNotEmpty) {
          for (var request in data) {
            try {
              if (request is Map<String, dynamic>) {
                requests.add(RequestData.fromJson(request));
              }
            } catch (e) {
              debugPrint("Parsing Error: $e");
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
  Future<bool> acceptRequest({
    required String uid,
    required String requestId,
  }) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseRequestUrl/services/proposals/",
        data: json.encode({"service_request": requestId}),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> cancelRequest({
    required String uid,
    required String requestId,
  }) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.delete(
        "$baseRequestUrl/services/proposals/$requestId/",
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
  Future<bool> isRequestAccepted({required String requestID}) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseRequestUrl/services/proposals/?service_request=$requestID",
        options: Options(headers: dioHeaders(token)),
      );
      final data = response;

      if (data.statusCode == 200) {
        var list = (data.data is List)
            ? data.data
            : (data.data is Map
                  ? (data.data["results"] ?? data.data["requests_acceptance"])
                  : []);
        if (list != null) {
          for (var request in list) {
            RequestAcceptance acceptance = RequestAcceptance.fromJson(request);
            if (acceptance.acceptance!.providerId ==
                SuccessGetProfileState.profile.user!.id) {
              return true;
            }
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<RequestAcceptance>?> getAcceptedRequest() async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        // expand=request means Django should inline the full ServiceRequest
        // object — no separate hydration calls needed.
        "$baseRequestUrl/services/proposals/?provider_me=true&expand=request",
        options: Options(headers: dioHeaders(token)),
      );

      final data = response;
      if (data.statusCode == 200) {
        List<RequestAcceptance> requests = [];
        var list = (data.data is List)
            ? data.data
            : (data.data is Map
                  ? (data.data["results"] ?? data.data["requests_acceptance"])
                  : []);
        if (list != null) {
          for (var request in list) {
            requests.add(RequestAcceptance.fromJson(request));
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
  Future<RequestData?> getRequestById({required String id}) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseRequestUrl/services/requests/$id/",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        return RequestData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> reloadProfile({required String request}) async {
    try {
      Profile profile = Profile();
      // final results = await store.collection("profiles").doc(request).get();

      return profile.rating!.contains(request);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addAppointment({required Appointment appointment}) async {
    try {
      final token = await Helpers.getString("token");
      debugPrint("Appointment Payload: ${json.encode(appointment.toJson())}");
      final response = await dio.post(
        "$baseUrl/interactions/appointments/",
        data: json.encode(appointment.toJson()),
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 201) {
        if (appointment.chatID != null) {
          await Helpers.saveString(appointment.chatID!, "yes");
        }
        return true;
      }
      debugPrint("POST APPOINTMENT FAILED: ${response.statusCode} - ${response.data}");
      return false;
    } catch (e) {
      if (e is DioException) {
        debugPrint("Dio Error: ${e.response?.statusCode} - ${e.response?.data}");
      }
      return false;
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
        var list = (data.data is List)
            ? data.data
            : (data.data is Map
                  ? (data.data["results"] ?? data.data["appointments"])
                  : []);
        
        if (list != null && list.isNotEmpty) {
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
  Future<List<RequestData>?> getRequests({
    double? lat,
    double? lng,
    double? radius,
    int? page,
    bool? targeted,
    String? catalogServiceId,
  }) async {
    return getRecentRequest(
      lat: lat,
      lng: lng,
      radius: radius,
      page: page,
      targeted: targeted,
      catalogServiceId: catalogServiceId,
    );
  }

  @override
  Future<List<RequestData>?> searchRequests({
    String? query,
    double? lat,
    double? lng,
    double? radius,
    int? page,
    String? catalogServiceId,
  }) async {
    final token = await Helpers.getString("token");
    try {
      Map<String, dynamic> params = {};
      if (lat != null) params['lat'] = lat;
      if (lng != null) params['lng'] = lng;
      if (radius != null) params['radius'] = radius;
      if (page != null) params['page'] = page;
      if (query != null && query.isNotEmpty && catalogServiceId == null) {
        params['search'] = query;
      }
      if (catalogServiceId != null) {
        params['catalog_service'] = catalogServiceId;
      }

      final response = await dio.get(
        "$baseRequestUrl/services/requests/",
        queryParameters: params,
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        List<RequestData> requests = [];
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey("results")) {
            data = response.data["results"];
          } else if (response.data.containsKey("requests")) {
            data = response.data["requests"];
          }
        }

        if (data.isNotEmpty) {
          for (var request in data) {
            try {
              if (request is Map<String, dynamic>) {
                requests.add(RequestData.fromJson(request));
              }
            } catch (e) {
              debugPrint("Parse Error: $e");
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
  Future<bool> cancelAppointment({required String id}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.delete(
        "$baseUrl/interactions/appointments/$id/",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
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
        data: json.encode(appointment.toJson()),
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
        data: json.encode({"amount": amount}),
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
  Future<bool> addPortfolioItem({
    required File image,
    String? description,
  }) async {
    try {
      final token = await Helpers.getString("token");
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path),
        if (description != null) 'description': description,
      });

      final response = await dio.post(
        "$baseUrl/accounts/portfolio/",
        data: formData,
        options: Options(headers: dioMultiPartHeaders(token)),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<ServicePackage> addServicePackage(ServicePackage package) async {
    final token = await Helpers.getString("token");
    final response = await dio.post(
      "$baseUrl/service-packages/",
      options: Options(headers: dioHeaders(token)),
      data: package.toJson(),
    );

    if (response.statusCode == 201) {
      return ServicePackage.fromJson(response.data);
    } else {
      debugPrint(response.data.toString());
      return ServicePackage();
    }
  }

  Future<List<ServicePackage>> getServicePackages() async {
    final token = await Helpers.getString("token");
    final response = await dio.get(
      "$baseUrl/service-packages/",
      options: Options(headers: dioHeaders(token)),
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => ServicePackage.fromJson(e))
          .toList();
    } else {
      debugPrint(response.data.toString());
      return [];
    }
  }
}
