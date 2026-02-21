import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class AddToFavoriteUseCase extends UseCase{
  final SeekerRepository repository;

  AddToFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.addToFavorite(userID: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }

}