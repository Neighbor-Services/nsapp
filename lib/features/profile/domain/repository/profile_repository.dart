import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/about.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/review.dart';
import 'package:nsapp/core/models/audit_log.dart';

abstract class ProfileRepository {
  Future<Either<Failure, bool>> createProfile(Profile profile, {String? profilePicturePath});
  Future<Either<Failure, bool>> updateToken();
  Future<Either<Failure, bool>> createAbout(About about);
  Future<Either<Failure, bool>> addReview(Review review);
  Future<Either<Failure, bool>> updateProfile(Profile profile, {String? profilePicturePath});
  Future<Either<Failure, bool>> deleteProfile(String id);
  Future<Either<Failure, bool>> deleteAbout(String id);
  Future<Either<Failure, List<Profile>>> getProfiles();
  Future<Either<Failure, Profile?>> getProfile(String id);
  Future<Either<Failure, Profile>> getProfileStream();
  Future<Either<Failure, AboutData>> getAboutStream(String userId);
  Future<Either<Failure, List<ReviewData>>> getReviewStream(String userId);
  Future<Either<Failure, String?>> initiateBackgroundCheck(String paymentIntentId);
  Future<Either<Failure, List<AuditLog>>> getAuditLogs();
}


