import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import '../repository/provider_repository.dart';

class AddPortfolioItemUseCase extends UseCase {
  final ProviderRepository repository;

  AddPortfolioItemUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    if (params is! AddPortfolioItemParams) {
      return Left(Failure(massege: "Invalid parameters"));
    }
    final results = await repository.addPortfolioItem(
      image: params.image,
      description: params.description!,
    );
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}

class AddPortfolioItemParams {
  final File image;
  final String? description;

  AddPortfolioItemParams({required this.image, this.description});
}
