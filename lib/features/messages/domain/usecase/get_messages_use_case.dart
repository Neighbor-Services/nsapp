import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/messages_repository.dart';
import 'package:nsapp/core/models/chat.dart';

class GetMessagesUseCase extends UseCase {
  final MessagesRepository repository;
  GetMessagesUseCase(this.repository);
  @override
  Future<Either<Failure, List<ChatMessage>>> call(params) async {
    final results = await repository.getMessages(params);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
