import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/core/models/failure.dart';

import '../../../../core/models/request_acceptance.dart';
import '../../../../core/models/request_data.dart';

import 'package:nsapp/core/models/request_search_params.dart';

abstract class ProviderRepository {
  Future<Either<Failure, List<RequestData>>> getRecentRequest({
    RequestSearchParams? params,
  });
  Future<Either<Failure, List<RequestData>>> getRequests({
    RequestSearchParams? params,
  });
  Future<Either<Failure, RequestData>> getRequestById({required String id});
  Future<Either<Failure, bool>> acceptRequest({
    required String uid,
    required String requestId,
  });
  Future<Either<Failure, bool>> cancelRequest({
    required String uid,
    required String requestId,
  });
  Future<Either<Failure, bool>> reloadProfile({required String requestId});
  Future<Either<Failure, bool>> addAppointment({
    required Appointment appointment,
  });
  Future<Either<Failure, List<RequestAcceptance>>> getAcceptedRequest();
  Future<Either<Failure, List<RequestData>>> searchRequests({
    RequestSearchParams? params,
  });
  Future<Either<Failure, List<AppointmentData>>> getAppointments();
  Future<Either<Failure, bool>> verifyAppointmentCode(String appointmentId, String code);

  Future<Either<Failure, bool>> cancelAppointment({required String id});
  Future<Either<Failure, bool>> updateAppointment({
    required Appointment appointment,
  });
  Future<Either<Failure, bool>> completeAppointment({
    required String id,
    required double amount,
  });
  Future<Either<Failure, bool>> isRequestAccepted({required String id});
  Future<Either<Failure, bool>> addPortfolioItem({
    required File image,
    String description,
  });
  Future<Either<Failure, ServicePackage>> addServicePackage(
    ServicePackage package,
  );
}
