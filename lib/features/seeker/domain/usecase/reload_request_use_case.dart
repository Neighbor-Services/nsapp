import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/request_data.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class ReloadRequestUseCase extends UseCase {
  final SeekerRepository repository;

  ReloadRequestUseCase(this.repository);
  @override
  Future<Either<Failure, RequestData>> call(params) async {
    final results = await repository.reloadRequest(request: params);

    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
