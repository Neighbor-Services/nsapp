import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/profile.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class GetPopularProviderRequestUseCase extends UseCase {
  final SeekerRepository repository;

  GetPopularProviderRequestUseCase(this.repository);
  @override
  Future<Either<Failure, List<Profile>>> call(params) async {
    final results = await repository.getPopularProviders();

    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
