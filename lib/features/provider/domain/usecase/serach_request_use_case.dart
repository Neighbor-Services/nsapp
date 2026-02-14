import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/request_data.dart';

import '../../../../core/models/failure.dart';
import '../repository/provider_repository.dart';

import 'package:nsapp/core/models/request_search_params.dart';

class SerachRequestUseCase
    extends UseCase<List<RequestData>, RequestSearchParams?> {
  final ProviderRepository repository;

  SerachRequestUseCase(this.repository);

  @override
  Future<Either<Failure, List<RequestData>>> call(
    RequestSearchParams? params,
  ) async {
    final results = await repository.searchRequests(params: params);

    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
