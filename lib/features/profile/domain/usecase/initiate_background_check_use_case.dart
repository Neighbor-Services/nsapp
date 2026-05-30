import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/profile/domain/repository/profile_repository.dart';

class InitiateBackgroundCheckUseCase implements UseCase<String?, BackgroundCheckParams> {
  final ProfileRepository repository;

  InitiateBackgroundCheckUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(BackgroundCheckParams params) async {
    return await repository.initiateBackgroundCheck(params.paymentIntentId);
  }
}


