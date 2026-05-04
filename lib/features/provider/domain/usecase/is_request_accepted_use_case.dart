import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/provider_repository.dart';

class IsRequestAcceptedUseCase extends UseCase<bool, dynamic> {
  final ProviderRepository repository;

  IsRequestAcceptedUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(dynamic params) async {
    if (params is Map<String, dynamic>) {
      return await repository.isRequestAccepted(
        id: params['id'],
        uid: params['uid'],
      );
    }
    return await repository.isRequestAccepted(id: params);
  }
}


