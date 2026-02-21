import 'package:dartz/dartz.dart';
import '../../../../core/models/failure.dart';
import '../../../../core/models/profile.dart';
import '../repository/seeker_repository.dart';

class MatchProvidersUseCase {
  final SeekerRepository repository;

  MatchProvidersUseCase(this.repository);

  Future<Either<Failure, List<Profile>>> call({
    required String description,
  }) async {
    return await repository.matchProviders(description: description);
  }
}
