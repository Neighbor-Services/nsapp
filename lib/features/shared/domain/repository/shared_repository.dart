import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/legal_document.dart';
import 'package:nsapp/core/models/report.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/models/subscription_plan.dart';
import 'package:nsapp/core/models/wallet.dart';

import '../../../../core/models/map_places.dart';
import '../../../../core/models/notification.dart';
import '../../../../core/models/place.dart';

abstract class SharedRepository {
  Future<Either<Failure, bool>> addNotification(Notification notification);

  Future<Either<Failure, bool>> addReport(Report report);

  Future<Either<Failure, bool>> setSeen(String notificationID);

  Future<Either<Failure, List<NotificationData>>> getMyNotifications();

  Future<Either<Failure, Place>> searchPlace({required String placeID});

  Future<Either<Failure, List<MapPlaces>>> searchPlaces({
    required String input,
  });
  Future<Either<Failure, List<Service>>> getServices();
  Future<Either<Failure, String>> addService(Service model);
  Future<Either<Failure, bool>> changeUserType(String type, String service);
  Future<Either<Failure, bool>> createDispute(Dispute dispute);
  Future<Either<Failure, Wallet>> getMyWallet();
  Future<Either<Failure, bool>> requestPayout(double amount);
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans();
  Future<Either<Failure, List<Dispute>>> getMyDisputes();
  Future<Either<Failure, String>> getStripeDashboardLink();
  Future<Either<Failure, List<LegalDocument>>> getLegalDocument(String docType);
}
