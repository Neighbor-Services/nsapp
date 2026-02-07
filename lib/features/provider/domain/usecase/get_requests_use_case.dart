import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/request_data.dart';

import '../../../../core/models/failure.dart';
import '../repository/provider_repository.dart';

import 'package:nsapp/core/models/request_search_params.dart';

class GetRequestsUseCase
    extends UseCase<List<RequestData>, RequestSearchParams?> {
  final ProviderRepository repository;

  GetRequestsUseCase(this.repository);
  @override
  Future<Either<Failure, List<RequestData>>> call(
    RequestSearchParams? params,
  ) async {
    final results = await repository.getRequests(params: params);

    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
