import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';

/// Reads the auth token from secure storage and returns it.
class GetTokenUsecase extends UseCase {
  @override
  Future<Either<Failure, String>> call(params) async {
    try {
      final token = await Helpers.getToken();
      return Right(token);
    } catch (e) {
      return Left(Failure(message: 'Failed to retrieve token'));
    }
  }
}
