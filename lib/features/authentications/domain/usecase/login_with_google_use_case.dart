import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/authentication_repository.dart';

class LoginWithGoogleUseCase extends UseCase {
  final AuthenticationRepository repository;

  LoginWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.loginWithGoogle();
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
