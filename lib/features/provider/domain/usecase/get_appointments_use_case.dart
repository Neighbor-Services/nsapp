import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/appointment.dart';
import '../repository/provider_repository.dart';

class GetAppointmentsUseCase extends UseCase<List<AppointmentData>, dynamic> {
  final ProviderRepository repository;

  GetAppointmentsUseCase(this.repository);
  @override
  Future<Either<Failure, List<AppointmentData>>> call(dynamic params) async {
    final results = await repository.getAppointments();
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
