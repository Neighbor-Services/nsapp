import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/core/models/appointment.dart';
import '../../../../core/models/rate.dart';

abstract class SeekerRepository {
  Future<Either<Failure, bool>> createRequest(Request request);
  Future<Either<Failure, bool>> rate(Rate rete);
  Future<Either<Failure, bool>> updateRequest(Request request);
  Future<Either<Failure, bool>> markAsDone(Request request);
  Future<Either<Failure, List<RequestData>>> myRequest();
  Future<Either<Failure, RequestData>> reloadRequest({required String request});
  Future<Either<Failure, List<Profile>>> getPopularProviders();
  Future<Either<Failure, List<Favorite>>> getMyFavorites();

  Future<Either<Failure, List<RequestAcceptance>>> getAcceptedUsers({
    required String request,
  });
  Future<Either<Failure, bool>> approvedRequest({
    required String user,
    required String serviceRequestId,
    required String proposalId,
  });
  Future<Either<Failure, bool>> cancelApprovedRequest({
    required String requestId,
  });
  Future<Either<Failure, bool>> deleteRequest({required String requestId});
  Future<Either<Failure, bool>> addToFavorite({required String userID});
  Future<Either<Failure, bool>> removeFromFavorite({required String userID});

  Future<Either<Failure, List<AppointmentData>>> getAppointments();
  Future<Either<Failure, List<Profile>>> searchProviders({
    double? ratingMin,
    double? priceMin,
    double? priceMax,
    String? categoryName,
    String? serviceName,
    String? city,
  });
  Future<Either<Failure, bool>> cancelAppointment({required String id});
  Future<Either<Failure, bool>> updateAppointment({
    required Appointment appointment,
  });
  Future<Either<Failure, bool>> completeAppointment({
    required String id,
    required double amount,
  });
  Future<Either<Failure, List<Profile>>> matchProviders({
    required String description,
  });
}
