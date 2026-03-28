import 'package:nsapp/core/models/legal_document.dart';
import 'package:nsapp/core/models/report.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/models/wallet.dart';
import 'package:nsapp/core/models/subscription_plan.dart';

import '../../../../../core/models/map_places.dart';
import '../../../../../core/models/notification.dart' as not;
import '../../../../../core/models/place.dart';

abstract class SharedRemoteDatasource {
  Future<bool> addNotification(not.Notification notification);

  Future<bool> addReport(Report report);
  Future<bool> setSeen(String notificationID);

  Future<List<not.NotificationData>?> getMyNotifications();

  Future<Place?> searchPlace({required String placeID});

  Future<List<MapPlaces>?> searchPlaces({required String input});

  Future<List<Service>?> getServices();
  Future<String?> addServices(Service model);
  Future<bool> updateUserType(String userType, String service);
  Future<bool> createDispute(Dispute dispute);
  Future<Wallet> getMyWallet();
  Future<bool> requestPayout(double amount);
  Future<List<SubscriptionPlan>?> getSubscriptionPlans();
  Future<List<Dispute>?> getMyDisputes();
  Future<String> getStripeDashboardLink();
  Future<List<LegalDocument>?> getLegalDocument(String docType);
}
