import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/request_search_params.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/data/datasource/remote/provider_remote_datasource.dart';
import 'package:nsapp/features/provider/domain/repository/provider_repository.dart';

import '../../../../core/services/hive_service.dart';

class ProviderRepositoryImpl extends ProviderRepository {
  final ProviderRemoteDatasource datasource;
  final HiveService hiveService;

  ProviderRepositoryImpl(this.datasource, this.hiveService);
  @override
  Future<Either<Failure, List<RequestData>>> getRecentRequest({
    RequestSearchParams? params,
  }) async {
    try {
      final results = await datasource.getRecentRequest(
        lat: params?.lat,
        lng: params?.lng,
        radius: params?.radius,
        page: params?.page,
        targeted: params?.targeted,
      );
      if (results != null) {
        if (params == null || params.page == null || params.page == 1) {
          await hiveService
              .getBox(HiveService.serviceRequestBox)
              .put('recent_requests', results);
        }
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('recent_requests');
      if (cached != null) return Right(List<RequestData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('recent_requests');
      if (cached != null) return Right(List<RequestData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> acceptRequest({
    required String uid,
    required String requestId,
  }) async {
    try {
      final results = await datasource.acceptRequest(
        uid: uid,
        requestId: requestId,
      );
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelRequest({
    required String uid,
    required String requestId,
  }) async {
    try {
      final results = await datasource.cancelRequest(
        uid: uid,
        requestId: requestId,
      );
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> reloadProfile({
    required String requestId,
  }) async {
    try {
      final results = await datasource.reloadProfile(request: requestId);
      return Right(results);
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<RequestAcceptance>>> getAcceptedRequest() async {
    try {
      final results = await datasource.getAcceptedRequest();
      if (results != null) {
        await hiveService
            .getBox(HiveService.serviceRequestBox)
            .put('accepted_requests', results);
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('accepted_requests');
      if (cached != null) return Right(List<RequestAcceptance>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('accepted_requests');
      if (cached != null) return Right(List<RequestAcceptance>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> addAppointment({
    required Appointment appointment,
  }) async {
    try {
      final results = await datasource.addAppointment(appointment: appointment);
      return Right(results);
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentData>>> getAppointments() async {
    try {
      final results = await datasource.getAppointment();
      if (results != null) {
        await hiveService
            .getBox(HiveService.appointmentBox)
            .put('provider_appointments', results);
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.appointmentBox)
          .get('provider_appointments');
      if (cached != null) return Right(List<AppointmentData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.appointmentBox)
          .get('provider_appointments');
      if (cached != null) return Right(List<AppointmentData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<RequestData>>> getRequests({
    RequestSearchParams? params,
  }) async {
    try {
      final results = await datasource.getRequests(
        lat: params?.lat,
        lng: params?.lng,
        radius: params?.radius,
        page: params?.page,
        targeted: params?.targeted,
      );
      if (results != null) {
        if (params == null || params.page == null || params.page == 1) {
          await hiveService
              .getBox(HiveService.serviceRequestBox)
              .put('all_requests', results);
        }
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('all_requests');
      if (cached != null) return Right(List<RequestData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('all_requests');
      if (cached != null) return Right(List<RequestData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<RequestData>>> searchRequests({
    RequestSearchParams? params,
  }) async {
    try {
      final results = await datasource.searchRequests(
        query: params?.query,
        lat: params?.lat,
        lng: params?.lng,
        radius: params?.radius,
        page: params?.page,
        catalogServiceId: params?.catalogServiceId,
      );
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelAppointment({required String id}) async {
    try {
      final isSuccess = await datasource.cancelAppointment(id: id);
      if (isSuccess) {
        return Right(true);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAppointment({
    required Appointment appointment,
  }) async {
    try {
      final isSuccess = await datasource.updateAppointment(
        appointment: appointment,
      );
      if (isSuccess) {
        return Right(true);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> completeAppointment({
    required String id,
    required double amount,
  }) async {
    try {
      final results = await datasource.completeAppointment(
        id: id,
        amount: amount,
      );
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> isRequestAccepted({required String id}) async {
    try {
      final isSuccess = await datasource.isRequestAccepted(requestID: id);
      if (isSuccess) {
        return Right(isSuccess);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> addPortfolioItem({
    required File image,
    String? description,
  }) async {
    try {
      final results = await datasource.addPortfolioItem(
        image: image,
        description: description,
      );
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, ServicePackage>> addServicePackage(
    ServicePackage package,
  ) async {
    try {
      final result = await datasource.addServicePackage(package);
      return Right(result);
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }
}
