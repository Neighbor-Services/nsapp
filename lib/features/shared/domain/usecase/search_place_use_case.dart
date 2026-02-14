import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/place.dart';
import '../repository/shared_repository.dart';

class SearchPlaceUseCase extends UseCase {
  final SharedRepository repository;

  SearchPlaceUseCase(this.repository);

  @override
  Future<Either<Failure, Place>> call(params) async {
    final results = await repository.searchPlace(placeID: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
