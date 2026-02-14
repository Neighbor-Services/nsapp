import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/seeker_repository.dart';

class CancelAppointmentUseCase extends UseCase {
  final SeekerRepository repository;

  CancelAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.cancelAppointment(id: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
