import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class ApproveProviderUseCase extends UseCase {
  final SeekerRepository repository;

  ApproveProviderUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.approvedRequest(
      user: params.uid,
      serviceRequestId: params.serviceRequestId,
      proposalId: params.proposalId,
    );
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
