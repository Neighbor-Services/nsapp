import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart' show Failure;
import 'package:nsapp/core/models/request_data.dart';

import '../repository/seeker_repository.dart';

class GetMyRequestUseCase extends UseCase {
  final SeekerRepository repository;

  GetMyRequestUseCase(this.repository);
  @override
  Future<Either<Failure, List<RequestData>>> call(params) async {
    final results = await repository.myRequest();
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
