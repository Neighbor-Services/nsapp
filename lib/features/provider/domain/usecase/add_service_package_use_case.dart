import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/features/provider/domain/repository/provider_repository.dart';

class AddServicePackageUseCase implements UseCase<ServicePackage, ServicePackage> {
  final ProviderRepository repository;

  AddServicePackageUseCase(this.repository);

  @override
  Future<Either<Failure, ServicePackage>> call(ServicePackage params) async {
    return await repository.addServicePackage(params);
  }
}
