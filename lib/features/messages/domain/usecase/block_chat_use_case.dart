import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import '../../../../core/models/failure.dart';
import '../repository/messages_repository.dart';

class BlockChatParams {
  final String conversationId;
  final String userId;
  BlockChatParams({required this.conversationId, required this.userId});
}

class BlockChatUseCase extends UseCase<Either<Failure, bool>, BlockChatParams> {
  final MessagesRepository repository;
  BlockChatUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(BlockChatParams params) async {
    return await repository.blockChat(params.conversationId, params.userId);
  }
}
