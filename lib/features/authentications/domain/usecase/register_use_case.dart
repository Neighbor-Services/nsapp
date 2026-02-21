import 'package:nsapp/core/helpers/use_case.dart';
import 'package:dartz/dartz.dart';

import 'package:nsapp/features/authentications/domain/repository/authentication_repository.dart';
import 'package:nsapp/core/models/failure.dart';

class RegisterUseCase extends UseCase {
  final AuthenticationRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.register(params.email, params.password);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
