import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/provider_repository.dart';

class CancelProviderAppointmentUseCase extends UseCase {
  final ProviderRepository repository;

  CancelProviderAppointmentUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.cancelAppointment(id: params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
