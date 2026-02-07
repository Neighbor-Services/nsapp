import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/dispute.dart';
import '../repository/shared_repository.dart';

class CreateDisputeUseCase extends UseCase {
  final SharedRepository repository;

  CreateDisputeUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    if (params is! Dispute) {
      return Left(Failure(massege: "Invalid parameters"));
    }
    return await repository.createDispute(params);
  }
}
