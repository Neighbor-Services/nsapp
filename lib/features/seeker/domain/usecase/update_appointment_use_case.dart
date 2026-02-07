import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/failure.dart';
import '../repository/seeker_repository.dart';

class UpdateSeekerAppointmentUseCase extends UseCase<bool, Appointment> {
  final SeekerRepository repository;

  UpdateSeekerAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(Appointment params) async {
    return await repository.updateAppointment(appointment: params);
  }
}
