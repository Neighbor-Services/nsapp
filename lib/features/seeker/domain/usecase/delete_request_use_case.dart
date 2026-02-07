import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class DeleteRequestUseCase extends UseCase{
  final SeekerRepository repository;

  DeleteRequestUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.deleteRequest(requestId: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}