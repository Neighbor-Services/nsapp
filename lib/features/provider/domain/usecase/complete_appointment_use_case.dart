import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/provider/domain/repository/provider_repository.dart';

class CompleteAppointmentUseCase
    extends UseCase<bool, CompleteAppointmentParams> {
  final ProviderRepository repository;

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
