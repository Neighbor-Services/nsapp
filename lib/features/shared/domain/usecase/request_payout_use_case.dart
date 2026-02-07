import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class RequestPayoutUseCase {
  final SharedRepository repository;

  RequestPayoutUseCase(this.repository);

  Future<Either<Failure, bool>> call(double amount) async {
    return await repository.requestPayout(amount);
  }
}
