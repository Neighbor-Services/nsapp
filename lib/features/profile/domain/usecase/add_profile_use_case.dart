import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/profile/domain/repository/profile_repository.dart';

class AddProfileUseCase extends UseCase {
  final ProfileRepository repository;

  AddProfileUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    try {
      final results = await repository.createProfile(params.profile, profilePicturePath: params.profilePicturePath);
      return results.fold(
        (failure) => left(failure),
        (success) => right(success),
      );
    } catch (e) {
      return left(Failure(message: e.toString().replaceAll("Exception: ", "")));
    }
  }
}



