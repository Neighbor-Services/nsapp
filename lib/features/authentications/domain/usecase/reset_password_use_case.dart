import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/authentication_repository.dart';

class ResetPasswordUseCase extends UseCase {
  final AuthenticationRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final p = params as ResetPasswordParams;
    final results = await repository.resetPassword(p.otp, p.password);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
