import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/authentication_repository.dart';

class VerifyRegisteredEmailUsecase extends UseCase{
  final AuthenticationRepository repository;

  VerifyRegisteredEmailUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.verifySignUpEmail(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}