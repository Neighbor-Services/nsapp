import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/map_places.dart';
import '../repository/shared_repository.dart';

class SearchPlacesUseCase extends UseCase {
  final SharedRepository repository;

  SearchPlacesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MapPlaces>>> call(params) async {
    final results = await repository.searchPlaces(input: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
