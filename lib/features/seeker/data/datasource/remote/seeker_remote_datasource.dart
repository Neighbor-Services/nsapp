import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/rate.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import '../../../../../core/models/request_data.dart';

abstract class SeekerRemoteDatasource {
  Future<bool> createRequest(Request request);
  Future<bool> rate(Rate rate);
  Future<List<RequestData>?> myRequest();
  Future<List<Profile>?> getPopularProviders();
  Future<List<RequestAcceptance>?> getAcceptedUsers({required String request});
  Future<List<Favorite>?> getMyFavorites();
  Future<bool> approveRequest({
    required String user,
    required String serviceRequestId,
    required String proposalId,
  });
  Future<bool> cancelApproveRequest({required String requestId});
  Future<bool> deleteRequest({required String requestId});
  Future<bool> updateRequest({required Request request});
  Future<bool> markAsDone({required Request request});
  Future<bool> addToFavorite({required String uid});
  Future<bool> removeFromFavorite({required String id});
  Future<RequestData?> reloadRequest({required String request});

  Future<List<AppointmentData>?> getAppointment();
  Future<List<Profile>?> searchProviders({
    double? ratingMin,
    double? priceMin,
    double? priceMax,
    String? categoryName,
    String? serviceName,
    String? city,
  });
  Future<bool> cancelAppointment({required String id});
  Future<bool> updateAppointment({required Appointment appointment});
  Future<bool> completeAppointment({
    required String id,
    required double amount,
  });
  Future<List<Profile>?> matchProviders({required String description});
}
