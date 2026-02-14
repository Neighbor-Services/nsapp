import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class GetStripeDashboardLinkUseCase {
  final SharedRepository repository;

  GetStripeDashboardLinkUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.getStripeDashboardLink();
  }
}
