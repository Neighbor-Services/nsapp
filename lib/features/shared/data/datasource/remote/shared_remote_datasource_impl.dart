import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/map_places.dart';
import 'package:nsapp/core/models/place.dart';
import 'package:nsapp/core/models/report.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/data/datasource/remote/shared_remote_datasource.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/models/wallet.dart';
import 'package:uuid/uuid.dart';
import 'package:nsapp/core/models/subscription_plan.dart';

import '../../../../../core/constants/string_constants.dart';
import '../../../../../core/models/notification.dart' as not;

class SharedRemoteDatasourceImpl extends SharedRemoteDatasource {
  @override
  Future<bool> addNotification(not.Notification notification) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/notifications/",
        data: json.encode(notification.toJson()),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<not.NotificationData>?> getMyNotifications() async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseUrl/notifications/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        List<not.NotificationData> notifications = [];
        var data = (response.data is List)
            ? response.data
            : response.data["results"];
        for (var notification in data) {
          notifications.add(not.NotificationData.fromJson(notification));
        }
        return notifications;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> addReport(Report report) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/moderation/reports/",
        data: json.encode(report.toJson()),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Place?> searchPlace({required String placeID}) async {
    try {
      Uuid uuid = Uuid();
      String token = uuid.v4();
      final response = await http
          .get(
            Uri.parse("$placeDetailsUrl/$placeID?sessionToken=$token"),
            headers: {
              "Content-Type": "application/json",
              "X-Goog-Api-Key": mapAPIKey,
              "X-Goog-FieldMask": "id,displayName,location",
            },
          )
          .timeout(Duration(seconds: 20));
      final result = json.decode(response.body);

      return Place.fromJson(result);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<List<MapPlaces>?> searchPlaces({required String input}) async {
    List<MapPlaces> locationRemoteModel = [];

    try {
      Uuid uuid = Uuid();
      var search = {"input": input, "sessionToken": uuid.v4()};
      final response = await http.post(
        Uri.parse(placesAutoCompleteUrl),
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": mapAPIKey,
        },
        body: json.encode(search),
      );
      if (response.statusCode == 200) {
        final results = json.decode(response.body)["suggestions"];

        for (var result in results) {
          locationRemoteModel.add(MapPlaces.fromJSON(result));
        }
      }
      return locationRemoteModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Service>?> getServices() async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseUrl/services/catalog-services/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        debugPrint("Services API Response: ${response.data}");
        List<Service> services = [];
        var data = (response.data is List)
            ? response.data
            : (response.data is Map
                  ? (response.data["results"] ?? response.data["services"])
                  : []);

        if (data != null) {
          for (var service in data) {
            if (service != null && service is Map) {
              try {
                services.add(
                  Service.fromJson(Map<String, dynamic>.from(service)),
                );
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          }
        }
        return services;
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<bool> setSeen(String notificationID) async {
    try {
      final String token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/notifications/$notificationID/mark_as_read/",
        options: Options(headers: dioHeaders(token)),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> addServices(Service model) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/services/catalog-services/",
        data: json.encode(model.toJson()),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data["id"]; // DRF returns id at root usually
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUserType(String userType, String service) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.patch(
        "$baseUrl/accounts/profile/update_me/",
        data: json.encode({"user_type": userType, "catalog_service": service}),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {}

      return false;
    }
  }

  @override
  Future<bool> createDispute(Dispute dispute) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/interactions/disputes/",
        data: json.encode(dispute.toJson()),
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
  Future<Wallet> getMyWallet() async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseUrl/payments/wallet/my_wallet/",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        return Wallet.fromJson(response.data);
      }
      throw Exception("Failed to load wallet");
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> requestPayout(double amount) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.post(
        "$baseUrl/payments/wallet/request_payout/",
        data: json.encode({"amount": amount}),
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
  Future<List<SubscriptionPlan>?> getSubscriptionPlans() async {
    try {
      final response = await dio.get("$baseUrl/payments/subscription-plans/");
      if (response.statusCode == 200) {
        List<SubscriptionPlan> plans = [];
        var data = (response.data is List)
            ? response.data
            : (response.data is Map
                  ? (response.data["results"] ?? response.data["plans"])
                  : []);

        if (data != null) {
          for (var plan in data) {
            try {
              if (plan != null && plan is Map<String, dynamic>) {
                plans.add(SubscriptionPlan.fromJson(plan));
              }
            } catch (e) {
              // Ignore parsing errors for individual items
            }
          }
        }
        return plans;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Dispute>?> getMyDisputes() async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseUrl/interactions/disputes/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        List<Dispute> disputes = [];
        var data = (response.data is List)
            ? response.data
            : (response.data is Map ? (response.data["results"] ?? []) : []);

        if (data != null) {
          for (var dispute in data) {
            if (dispute != null && dispute is Map<String, dynamic>) {
              disputes.add(Dispute.fromJson(dispute));
            }
          }
        }
        return disputes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> getStripeDashboardLink() async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseUrl/payments/wallet/stripe-dashboard/",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        return response.data["url"];
      }
      throw Exception("Failed to get Stripe Dashboard link");
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['error'] ?? "An error occurred");
      }
      throw Exception(e.toString());
    }
  }
}
