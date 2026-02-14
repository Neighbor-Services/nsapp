import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/shared_repository.dart';

class AddReportUseCase extends UseCase{
  final SharedRepository repository;

  AddReportUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.addReport(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}