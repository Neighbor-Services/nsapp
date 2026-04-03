import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/authentications/domain/repository/authentication_repository.dart';

class DeleteAccountUseCase extends UseCase {
  final AuthenticationRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call([dynamic params]) async {
    final results = await repository.deleteAccount();
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
