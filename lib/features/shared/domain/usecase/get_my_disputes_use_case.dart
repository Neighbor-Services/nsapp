import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class GetMyDisputesUseCase extends UseCase {
  final SharedRepository repository;

  GetMyDisputesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Dispute>>> call(params) async {
    return await repository.getMyDisputes();
  }
}
