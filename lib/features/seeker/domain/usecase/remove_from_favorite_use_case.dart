import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class RemoveFromFavoriteUseCase extends UseCase{
  final SeekerRepository repository;

  RemoveFromFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.removeFromFavorite(userID: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }

}