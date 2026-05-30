import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/profile_repository.dart';

class UpdateProfileUseCase extends UseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    try {
      final results = await repository.updateProfile(params.profile, profilePicturePath: params.profilePicturePath);
      return results.fold(
        (failure) => left(failure),
        (success) => right(success),
      );
    } on Exception {
      return left(Failure(message: 'Failed to add profile'));
    }
  }
}



