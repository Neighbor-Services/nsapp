import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/provider_repository.dart';

class CancelRequestUseCase extends UseCase<bool, dynamic> {
  final ProviderRepository repository;

  CancelRequestUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(dynamic params) async {
    final results = await repository.cancelRequest(
      uid: params.uid,
      requestId: params.serviceRequestId,
    );

    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
