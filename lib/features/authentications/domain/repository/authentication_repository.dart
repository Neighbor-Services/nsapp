import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, bool>> register(String email, String password);
  Future<Either<Failure, bool>> registerWithGoogle();
  Future<Either<Failure, bool>> resetPassword(String otp, String password);
  Future<Either<Failure, bool>> login(String email, String password);
  Future<Either<Failure, bool>> loginWithGoogle();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> verifySignUpEmail(String otp);
  Future<Either<Failure, bool>> changePassword(
    String oldPassword,
    String newPassword,
  );

  Future<Either<Failure, bool>> verifyEmail(String otp);
  Future<Either<Failure, bool>> sentEmailVerification(String email);
  Future<Either<Failure, bool>> requestPasswordReset(String email);
  Future<Either<Failure, bool>> loginWithApple();
  Future<Either<Failure, bool>> deleteAccount();
}
