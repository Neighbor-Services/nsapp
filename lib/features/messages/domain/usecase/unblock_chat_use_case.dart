import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import '../../../../core/models/failure.dart';
import '../repository/messages_repository.dart';

class UnblockChatParams {
  final String conversationId;
  final String userId;
  UnblockChatParams({required this.conversationId, required this.userId});
}

class UnblockChatUseCase extends UseCase<Either<Failure, bool>, UnblockChatParams> {
  final MessagesRepository repository;
  UnblockChatUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UnblockChatParams params) async {
    return await repository.unblockChat(params.conversationId, params.userId);
  }
}
