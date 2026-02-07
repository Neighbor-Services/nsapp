import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/profile_repository.dart';

class AddReviewUseCase extends UseCase {
  final ProfileRepository repository;

  AddReviewUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    try {
      final results = await repository.addReview(params);
      return results.fold(
        (failure) => left(failure),
        (success) => right(success),
      );
    } on Exception {
      return left(Failure(massege: 'Failed to add profile'));
    }
  }
}
