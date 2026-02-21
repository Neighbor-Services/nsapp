import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class SetSeenNotificationUseCase extends UseCase{
  final SharedRepository repository;

  SetSeenNotificationUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.setSeen(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}