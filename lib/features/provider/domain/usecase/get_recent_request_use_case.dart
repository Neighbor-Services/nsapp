import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/features/provider/domain/repository/provider_repository.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/request_data.dart';

import 'package:nsapp/core/models/request_search_params.dart';

class GetRecentRequestUseCase
    extends UseCase<List<RequestData>, RequestSearchParams?> {
  final ProviderRepository repository;

  GetRecentRequestUseCase(this.repository);
  @override
  Future<Either<Failure, List<RequestData>>> call(
    RequestSearchParams? params,
  ) async {
    final results = await repository.getRecentRequest(params: params);

    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
