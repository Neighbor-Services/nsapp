
import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/profile.dart';

import '../../../../core/models/failure.dart';
import '../repository/profile_repository.dart';

class GetProfileStreamUseCase extends UseCase{
  final ProfileRepository repository;

  GetProfileStreamUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(params) async {
    final results = await repository.getProfileStream();
    return results.fold(
          (failure) => Left(failure),
          (profile) => Right(profile),
    );
  }
}