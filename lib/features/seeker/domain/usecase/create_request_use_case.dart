import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/seeker/domain/repository/seeker_repository.dart';

class CreateRequestUseCase extends UseCase {
  final SeekerRepository repository;

  CreateRequestUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.createRequest(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
