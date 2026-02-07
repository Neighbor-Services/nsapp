import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/rate.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/seeker/data/datasource/remote/seeker_remote_datasource.dart';
import 'package:nsapp/features/seeker/domain/repository/seeker_repository.dart';

import 'package:nsapp/core/models/appointment.dart';

import '../../../../core/services/hive_service.dart';

class SeekerRepositoryImpl extends SeekerRepository {
  final SeekerRemoteDatasource datasource;
  final HiveService hiveService;

  SeekerRepositoryImpl(this.datasource, this.hiveService);

  @override
  Future<Either<Failure, bool>> createRequest(Request request) async {
    try {
      final results = await datasource.createRequest(request);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<RequestData>>> myRequest() async {
    try {
      final results = await datasource.myRequest();
      if (results != null) {
        await hiveService
            .getBox(HiveService.serviceRequestBox)
            .put('my_requests', results);
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('my_requests');
      if (cached != null) return Right(List<RequestData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.serviceRequestBox)
          .get('my_requests');
      if (cached != null) return Right(List<RequestData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<RequestAcceptance>>> getAcceptedUsers({
    required String request,
  }) async {
    try {
      final results = await datasource.getAcceptedUsers(request: request);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> approvedRequest({
    required String user,
    required String serviceRequestId,
    required String proposalId,
  }) async {
    try {
      final results = await datasource.approveRequest(
        user: user,
        serviceRequestId: serviceRequestId,
        proposalId: proposalId,
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
  Future<Either<Failure, RequestData>> reloadRequest({
    required String request,
  }) async {
    try {
      final results = await datasource.reloadRequest(request: request);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelApprovedRequest({
    required String requestId,
  }) async {
    try {
      final results = await datasource.cancelApproveRequest(
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
  Future<Either<Failure, bool>> deleteRequest({
    required String requestId,
  }) async {
    try {
      final results = await datasource.deleteRequest(requestId: requestId);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> updateRequest(Request request) async {
    try {
      final results = await datasource.updateRequest(request: request);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getPopularProviders() async {
    try {
      final results = await datasource.getPopularProviders();
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> addToFavorite({required String userID}) async {
    try {
      final results = await datasource.addToFavorite(uid: userID);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavorite({
    required String userID,
  }) async {
    try {
      final results = await datasource.removeFromFavorite(id: userID);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<Favorite>>> getMyFavorites() async {
    try {
      final results = await datasource.getMyFavorites();
      if (results != null) {
        await hiveService
            .getBox(HiveService.settingsBox)
            .put('my_favorites', results);
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.settingsBox)
          .get('my_favorites');
      if (cached != null) return Right(List<Favorite>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.settingsBox)
          .get('my_favorites');
      if (cached != null) return Right(List<Favorite>.from(cached));
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
            .put('seeker_appointments', results);
        return Right(results);
      }
      final cached = hiveService
          .getBox(HiveService.appointmentBox)
          .get('seeker_appointments');
      if (cached != null) return Right(List<AppointmentData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.appointmentBox)
          .get('seeker_appointments');
      if (cached != null) return Right(List<AppointmentData>.from(cached));
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> searchProviders({
    double? ratingMin,
    double? priceMin,
    double? priceMax,
    String? categoryName,
    String? serviceName,
    String? city,
  }) async {
    try {
      final results = await datasource.searchProviders(
        ratingMin: ratingMin,
        priceMin: priceMin,
        priceMax: priceMax,
        categoryName: categoryName,
        serviceName: serviceName,
        city: city,
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
  Future<Either<Failure, bool>> markAsDone(Request request) async {
    try {
      final results = await datasource.markAsDone(request: request);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> rate(Rate rete) async {
    try {
      final results = await datasource.rate(rete);
      if (results) {
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
  Future<Either<Failure, List<Profile>>> matchProviders({
    required String description,
  }) async {
    try {
      final results = await datasource.matchProviders(description: description);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }
}
