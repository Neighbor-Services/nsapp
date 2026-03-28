import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/legal_document.dart';
import 'package:nsapp/core/models/map_places.dart';
import 'package:nsapp/core/models/notification.dart';
import 'package:nsapp/core/models/place.dart';
import 'package:nsapp/core/models/report.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/models/wallet.dart';
import 'package:nsapp/core/models/subscription_plan.dart';
import 'package:nsapp/features/shared/data/datasource/remote/shared_remote_datasource.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

import '../../../../core/services/hive_service.dart';

class SharedRepositoryImpl extends SharedRepository {
  final SharedRemoteDatasource datasource;
  final HiveService hiveService;

  SharedRepositoryImpl(this.datasource, this.hiveService);

  @override
  Future<Either<Failure, bool>> addNotification(
    Notification notification,
  ) async {
    try {
      final results = await datasource.addNotification(notification);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<NotificationData>>> getMyNotifications() async {
    try {
      final results = await datasource.getMyNotifications();
      if (results != null) {
        await hiveService
            .getBox(HiveService.settingsBox)
            .put('my_notifications', results);
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.settingsBox)
          .get('my_notifications');
      if (cached != null) return Right(List<NotificationData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.settingsBox)
          .get('my_notifications');
      if (cached != null) return Right(List<NotificationData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> addReport(Report report) async {
    try {
      final results = await datasource.addReport(report);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, Place>> searchPlace({required String placeID}) async {
    try {
      final results = await datasource.searchPlace(placeID: placeID);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<MapPlaces>>> searchPlaces({
    required String input,
  }) async {
    try {
      final results = await datasource.searchPlaces(input: input);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getServices() async {
    try {
      final results = await datasource.getServices();
      if (results != null) {
        await hiveService
            .getBox(HiveService.serviceRequestBox)
            .put('all_services', results);
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('all_services');
      if (cached != null) return Right(List<Service>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('all_services');
      if (cached != null) return Right(List<Service>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> setSeen(String notificationID) async {
    try {
      final results = await datasource.setSeen(notificationID);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, String>> addService(Service model) async {
    try {
      final results = await datasource.addServices(model);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> changeUserType(
    String type,
    String service,
  ) async {
    try {
      final results = await datasource.updateUserType(type, service);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> createDispute(Dispute dispute) async {
    try {
      final results = await datasource.createDispute(dispute);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, Wallet>> getMyWallet() async {
    try {
      final results = await datasource.getMyWallet();
      await hiveService
          .getBox(HiveService.settingsBox)
          .put('my_wallet', results);
      return Right(results);
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.settingsBox)
          .get('my_wallet');
      if (cached != null) return Right(cached as Wallet);
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPayout(double amount) async {
    try {
      final results = await datasource.requestPayout(amount);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans() async {
    try {
      final results = await datasource.getSubscriptionPlans();
      if (results != null) {
        try {
          final jsonList = results.map((e) => e.toJson()).toList();
          await hiveService
              .getBox(HiveService.settingsBox)
              .put('subscription_plans', jsonList);
        } catch (e) {
          // Ignore caching errors
        }
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.settingsBox)
          .get('subscription_plans');
      if (cached != null) {
        final plans = (cached as List)
            .map((e) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(plans);
      }
      return Left(Failure(massege: "Failed to load plans"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<Dispute>>> getMyDisputes() async {
    try {
      final results = await datasource.getMyDisputes();
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, String>> getStripeDashboardLink() async {
    try {
      final url = await datasource.getStripeDashboardLink();
      return Right(url);
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LegalDocument>>> getLegalDocument(
    String docType,
  ) async {
    try {
      final result = await datasource.getLegalDocument(docType);
      if (result != null) {
        return Right(result);
      }
      return Left(Failure(massege: "Document not found"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }
}
