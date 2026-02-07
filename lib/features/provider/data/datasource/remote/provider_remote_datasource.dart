import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'dart:io';

import '../../../../../core/models/request_acceptance.dart';
import '../../../../../core/models/request_data.dart';

abstract class ProviderRemoteDatasource {
  Future<List<RequestData>?> getRecentRequest({
    double? lat,
    double? lng,
    double? radius,
    int? page,
    bool? targeted,
  });
  Future<List<RequestData>?> getRequests({
    double? lat,
    double? lng,
    double? radius,
    int? page,
    bool? targeted,
  });
  Future<List<RequestData>?> searchRequests({
    String? query,
    double? lat,
    double? lng,
    double? radius,
    int? page,
    String? catalogServiceId,
  });
  Future<bool> acceptRequest({required String uid, required String requestId});
  Future<bool> cancelRequest({required String uid, required String requestId});
  Future<List<RequestAcceptance>?> getAcceptedRequest();
  Future<List<AppointmentData>?> getAppointment();
  Future<bool> reloadProfile({required String request});
  Future<bool> addAppointment({required Appointment appointment});
  Future<bool> cancelAppointment({required String id});
  Future<bool> updateAppointment({required Appointment appointment});
  Future<bool> completeAppointment({
    required String id,
    required double amount,
  });
  Future<bool> isRequestAccepted({required String requestID});
  Future<bool> addPortfolioItem({required File image, String? description});
  Future<ServicePackage> addServicePackage(ServicePackage package);
}
