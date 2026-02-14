import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/profile_repository.dart';

class AddAboutUseCase extends UseCase {
  final ProfileRepository repository;

  AddAboutUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(about) async {
    try {
      final results = await repository.createAbout(about);
      return results.fold(
        (failure) => Left(failure),
        (success) => Right(success),
      );
    } on Exception {
      return Left(Failure(massege: 'Failed to add profile'));
    }
  }
}
