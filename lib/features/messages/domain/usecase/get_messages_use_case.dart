import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';

import '../../../../core/models/failure.dart';
import '../repository/messages_repository.dart';
import 'package:nsapp/core/models/chat.dart';

class GetMessagesParams {
  final String receiver;
  final String? before;
  GetMessagesParams({required this.receiver, this.before});
}

class GetMessagesUseCase extends UseCase<Either<Failure, List<ChatMessage>>, GetMessagesParams> {
  final MessagesRepository repository;
  GetMessagesUseCase(this.repository);
  @override
  Future<Either<Failure, List<ChatMessage>>> call(GetMessagesParams params) async {
    return await repository.getMessages(params.receiver, before: params.before);
  }
}


