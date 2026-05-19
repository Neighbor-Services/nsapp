import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/audit_log.dart';
import 'package:nsapp/features/profile/domain/repository/profile_repository.dart';

class GetAuditLogsUseCase extends UseCase<List<AuditLog>, NoParams> {
  final ProfileRepository repository;

  GetAuditLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AuditLog>>> call(NoParams params) async {
    return await repository.getAuditLogs();
  }
}


