import 'package:nsapp/features/authentications/data/datasource/remote/authentication_remote_data_source.dart';
import 'package:nsapp/features/authentications/domain/repository/authentication_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';

class AuthenicationRepositoryImpl extends AuthenticationRepository {
  final AuthenticationRemoteDataSource dataSource;

  AuthenicationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, bool>> register(String email, String password) async {
    try {
      final isSuccess = await dataSource.register(email, password);
      if (isSuccess) {
        return Right(isSuccess);
      }
      return Left(Failure(massege: "e.message"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> login(String email, String password) async {
    try {
      final user = await dataSource.login(email, password);
      if (user != null) {
        return Right(user);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await dataSource.logout();
      return right(true);
    } catch (e) {
      return left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
    String otp,
    String password,
  ) async {
    try {
      final results = await dataSource.resetPassword(otp, password);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> loginWithGoogle() async {
    try {
      final results = await dataSource.loginWithGoogle();
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerWithGoogle() async {
    try {
      final results = await dataSource.registerWithGoogle();
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifySignUpEmail(String otp) async {
    try {
      final results = await dataSource.verifyRegistration(otp);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final results = await dataSource.changePassword(oldPassword, newPassword);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyEmail(String otp) async {
    try {
      final results = await dataSource.verifyEmail(otp);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sentEmailVerification(String email) async {
    try {
      final results = await dataSource.sendEmailVerification(email);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPasswordReset(String email) async {
    try {
      final results = await dataSource.requestPasswordReset(email);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: e.toString()));
    }
  }
}
