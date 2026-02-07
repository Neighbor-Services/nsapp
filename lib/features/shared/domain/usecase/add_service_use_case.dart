import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class AddServiceUseCase extends UseCase {
  final SharedRepository repository;

  AddServiceUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(params) async {
    final results = await repository.addService(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
