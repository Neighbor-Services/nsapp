import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import '../../../../core/models/failure.dart';
import '../repository/authentication_repository.dart';

class SendEmailVerificationUseCase extends UseCase {
  final AuthenticationRepository repository;

  SendEmailVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.sentEmailVerification(params as String);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
