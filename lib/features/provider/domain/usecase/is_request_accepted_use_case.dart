import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/provider_repository.dart';

class IsRequestAcceptedUseCase extends UseCase<bool, dynamic> {
  final ProviderRepository repository;

  IsRequestAcceptedUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(dynamic params) async {
    final results = await repository.isRequestAccepted(id: params);

    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
