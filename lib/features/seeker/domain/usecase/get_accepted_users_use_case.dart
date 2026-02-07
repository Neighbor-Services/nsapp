
import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/request_acceptance.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class GetAcceptedUsersUseCase extends UseCase{
  final SeekerRepository repository;

  GetAcceptedUsersUseCase(this.repository);
  @override
  Future<Either<Failure, List<RequestAcceptance>> > call(params) async {
    final results = await repository.getAcceptedUsers(request: params);

    return results.fold((l) => Left(l), (r) => Right(r));
  }

}