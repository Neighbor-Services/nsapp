import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/about.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/review.dart';
import 'package:nsapp/features/profile/data/datasource/remote/profile_remote_datasource.dart';
import 'package:nsapp/features/profile/domain/repository/profile_repository.dart';
import 'package:nsapp/core/services/hive_service.dart';
import 'package:nsapp/core/models/audit_log.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final HiveService hiveService;

  ProfileRepositoryImpl(this.remoteDataSource, this.hiveService);

  @override
  Future<Either<Failure, List<AuditLog>>> getAuditLogs() async {
    try {
      final logs = await remoteDataSource.getAuditLogs();
      return right(logs);
    } catch (e) {
      return left(Failure(message: 'Failed to fetch activity history: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> createProfile(Profile profile, {String? profilePicturePath}) async {
    try {
      final isSuccess = await remoteDataSource.addProfile(profile, profilePicturePath: profilePicturePath);
      if (isSuccess) {
        return right(true);
      }
      return left(Failure(message: 'Failed to create profile'));
    } catch (e) {
      return left(Failure(message: e.toString().replaceAll("Exception: ", "")));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProfile(Profile profile, {String? profilePicturePath}) async {
    try {
      final isSuccess = await remoteDataSource.updateProfile(profile, profilePicturePath: profilePicturePath);
      if (isSuccess) {
        return right(true);
      }
      return left(Failure(message: 'Failed to update profile'));
    } on Exception {
      return left(Failure(message: 'Failed to update profile'));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getProfiles() async {
    try {
      // 1. Fetch from remote
      final profiles = await remoteDataSource.getProfiles();

      if (profiles.isNotEmpty) {
        // 2. Update Cache
        await hiveService
            .getBox(HiveService.profileBox)
            .put('all_profiles', profiles);
        return right(profiles);
      }

      // 3. Fallback to Cache
      final cached = hiveService
          .getBox(HiveService.profileBox)
          .get('all_profiles');
      if (cached != null) {
        return right(List<Profile>.from(cached));
      }

      return left(Failure(message: 'Profiles not found'));
    } on Exception {
      // 4. Fallback to Cache on error
      final cached = hiveService
          .getBox(HiveService.profileBox)
          .get('all_profiles');
      if (cached != null) {
        return right(List<Profile>.from(cached));
      }
      return left(Failure(message: 'Failed to get profiles'));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfile(String id) async {
    try {
      // 1. Fetch from remote
      final profile = await remoteDataSource.getProfile(id);

      if (profile != null) {
        // 2. Update Cache
        await hiveService
            .getBox(HiveService.profileBox)
            .put('profile_$id', profile);
        return right(profile);
      }

      // 3. Fallback to Cache
      final cached = hiveService
          .getBox(HiveService.profileBox)
          .get('profile_$id');
      if (cached != null) {
        return right(cached as Profile);
      }

      return left(Failure(message: 'Profile not found'));
    } on Exception {
      // 4. Fallback to Cache on error
      final cached = hiveService
          .getBox(HiveService.profileBox)
          .get('profile_$id');
      if (cached != null) {
        return right(cached as Profile);
      }
      return left(Failure(message: 'Failed to get profile'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProfile(String id) async {
    try {
      final isSuccess = await remoteDataSource.deleteProfile(id);
      if (isSuccess) {
        return right(true);
      }
      return left(Failure(message: 'Failed to delete profile'));
    } on Exception {
      return left(Failure(message: 'Failed to delete profile'));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfileStream() async {
    try {
      // 1. Fetch from remote
      final profile = await remoteDataSource.getProfileStream();

      if (profile != null) {
        // 2. Update Cache
        await hiveService
            .getBox(HiveService.profileBox)
            .put('my_profile', profile);
        return Right(profile);
      }

      // 3. Fallback to Cache
      final cached = hiveService
          .getBox(HiveService.profileBox)
          .get('my_profile');
      if (cached != null) {
        return Right(cached as Profile);
      }

      return Left(Failure(message: 'Profile not found'));
    } on Exception {
      // 4. Fallback to Cache on error
      final cached = hiveService
          .getBox(HiveService.profileBox)
          .get('my_profile');
      if (cached != null) {
        return Right(cached as Profile);
      }
      return Left(Failure(message: 'Failed to get profile'));
    }
  }

  @override
  Future<Either<Failure, bool>> createAbout(About about) async {
    try {
      final isSuccess = await remoteDataSource.addAbout(about);
      if (isSuccess) {
        return Right(isSuccess);
      }
      return Left(Failure(message: 'Failed to delete profile'));
    } on Exception {
      return Left(Failure(message: 'Failed to delete profile'));
    }
  }

  @override
  Future<Either<Failure, AboutData>> getAboutStream(String userId) async {
    try {
      final profile = await remoteDataSource.getAboutStream(userId);
      if (profile != null) {
        return Right(profile);
      }
      return Left(Failure(message: 'Profile not found'));
    } on Exception {
      return Left(Failure(message: 'Failed to get profile'));
    }
  }

  @override
  Future<Either<Failure, bool>> addReview(Review review) async {
    try {
      final isSuccess = await remoteDataSource.addReview(review);
      if (isSuccess) {
        return Right(isSuccess);
      }
      return Left(Failure(message: 'Failed to delete profile'));
    } on Exception {
      return Left(Failure(message: 'Failed to delete profile'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewData>>> getReviewStream(
    String userId,
  ) async {
    try {
      final results = await remoteDataSource.getReviews(userId);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(message: 'Profile not found'));
    } on Exception {
      return Left(Failure(message: 'Failed to get profile'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateToken() async {
    try {
      final isSuccess = await remoteDataSource.updateDeviceToken();
      if (isSuccess) {
        return right(true);
      }
      return left(Failure(message: 'Failed to create profile'));
    } on Exception {
      return left(Failure(message: 'Failed to create profile'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAbout(String id) async {
    try {
      final isSuccess = await remoteDataSource.deleteAboutStream(id);
      if (isSuccess) {
        return right(true);
      }
      return left(Failure(message: 'Failed to create profile'));
    } on Exception {
      return left(Failure(message: 'Failed to create profile'));
    }
  }

  @override
  Future<Either<Failure, String?>> initiateBackgroundCheck(String paymentIntentId) async {
    try {
      final url = await remoteDataSource.initiateBackgroundCheck(paymentIntentId);
      if (url != null) {
        return Right(url);
      }
      return Left(Failure(message: 'Failed to initiate background check'));
    } on Exception {
      return Left(Failure(message: 'Failed to initiate background check'));
    }
  }
}



