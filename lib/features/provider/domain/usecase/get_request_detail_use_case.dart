import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/request_data.dart';
import '../repository/provider_repository.dart';

class GetRequestDetailUseCase extends UseCase<RequestData, String> {
  final ProviderRepository repository;

  GetRequestDetailUseCase(this.repository);

  @override
  Future<Either<Failure, RequestData>> call(String params) async {
    return repository.getRequestById(id: params);
  }
}
