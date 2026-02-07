import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/provider_repository.dart';

class AddAppointmentUseCase extends UseCase<bool, dynamic> {
  final ProviderRepository repository;

  AddAppointmentUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(dynamic params) async {
    final results = await repository.addAppointment(appointment: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
