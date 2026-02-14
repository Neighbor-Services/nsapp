import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/profile/domain/repository/profile_repository.dart';

class GetProfileUseCase extends UseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile?>> call(params) async {
    final results = await repository.getProfile(params);
    return results.fold(
      (failure) => Left(failure),
      (profile) => Right(profile),
    );
  }
}
