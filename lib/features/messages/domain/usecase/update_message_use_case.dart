import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/features/messages/domain/repository/messages_repository.dart';

class UpdateMessageUseCase extends UseCase {
  final MessagesRepository repository;
  UpdateMessageUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(params) async {
    final results = await repository.updateMessage(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
