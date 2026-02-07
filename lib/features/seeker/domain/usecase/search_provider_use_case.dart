import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/profile.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class SearchProviderUseCase extends UseCase {
  final SeekerRepository repository;

  SearchProviderUseCase(this.repository);
  @override
  Future<Either<Failure, List<Profile>>> call(dynamic params) async {
    if (params is! SearchProviderParams) {
      return Left(Failure(massege: "Invalid properties"));
    }
    final results = await repository.searchProviders(
      ratingMin: params.ratingMin,
      priceMin: params.priceMin,
      priceMax: params.priceMax,
      categoryName: params.categoryName,
      serviceName: params.serviceName,
      city: params.city,
    );
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}

class SearchProviderParams {
  final double? ratingMin;
  final double? priceMin;
  final double? priceMax;
  final String? categoryName;
  final String? serviceName;
  final String? city;

  SearchProviderParams({
    this.ratingMin,
    this.priceMin,
    this.priceMax,
    this.categoryName,
    this.serviceName,
    this.city,
  });
}
