import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import '../../../../core/models/failure.dart';
import '../repository/authentication_repository.dart';

class RequestPasswordResetUseCase extends UseCase {
  final AuthenticationRepository repository;

  RequestPasswordResetUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.requestPasswordReset(params as String);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
