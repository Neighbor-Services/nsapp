import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/profile/domain/repository/profile_repository.dart';

class AddProfileUseCase extends UseCase {
  final ProfileRepository repository;

  AddProfileUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(profile) async {
    try {
      final results = await repository.createProfile(profile);
      return results.fold(
        (failure) => left(failure),
        (success) => right(success),
      );
    } on Exception {
      return left(Failure(massege: 'Failed to add profile'));
    }
  }
}
