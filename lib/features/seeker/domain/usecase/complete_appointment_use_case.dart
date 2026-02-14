import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/features/seeker/domain/repository/seeker_repository.dart';

class CompleteAppointmentUseCase
    extends UseCase<bool, CompleteAppointmentParams> {
  final SeekerRepository repository;

  CompleteAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(CompleteAppointmentParams params) async {
    return await repository.completeAppointment(
      id: params.id,
      amount: params.amount,
    );
  }
}

class CompleteAppointmentParams {
  final String id;
  final double amount;

  CompleteAppointmentParams({required this.id, required this.amount});
}
