import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/provider/domain/repository/provider_repository.dart';

class VerifyAppointmentCodeUseCase {
  final ProviderRepository repository;
  VerifyAppointmentCodeUseCase(this.repository);

  Future<Either<Failure, bool>> call(String appointmentId, String code) async {
    return await repository.verifyAppointmentCode(appointmentId, code);
  }
}
