import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';
import 'package:nsapp/core/helpers/use_case.dart';

class ChangeUserTypeUseCase extends UseCase {
  final SharedRepository repository;
  ChangeUserTypeUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.changeUserType(
      params["type"],
      params["service"],
    );
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
