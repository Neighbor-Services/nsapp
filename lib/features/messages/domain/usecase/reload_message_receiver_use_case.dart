import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/profile.dart';

import '../../../../core/models/failure.dart';
import '../repository/messages_repository.dart';

class ReloadMessageReceiverUseCase extends UseCase{
  final MessagesRepository repository;
  ReloadMessageReceiverUseCase(this.repository);
  @override
  Future<Either<Failure, Profile>> call(params) async {
    final results = await repository.reloadMessageReceiver(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}