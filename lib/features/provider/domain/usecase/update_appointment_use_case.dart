import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/failure.dart';
import '../repository/provider_repository.dart';

class UpdateProviderAppointmentUseCase extends UseCase<bool, Appointment> {
  final ProviderRepository repository;

  UpdateProviderAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(Appointment params) async {
    return await repository.updateAppointment(appointment: params);
  }
}
