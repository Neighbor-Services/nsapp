import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class GetServicesUsecase extends UseCase {
  final SharedRepository repository;

  GetServicesUsecase(this.repository);
  @override
  Future<Either<Failure, List<Service>>> call(params) async {
    final results = await repository.getServices();
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
