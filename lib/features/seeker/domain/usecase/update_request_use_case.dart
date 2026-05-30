import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class UpdateRequestUseCase extends UseCase{
  final SeekerRepository repository;

  UpdateRequestUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    if (params is RequestParams) {
      return await repository.updateRequest(params.request, imagePath: params.imagePath);
    }
    return await repository.updateRequest(params);
  }
}

