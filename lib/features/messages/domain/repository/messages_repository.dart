import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/chat.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/message.dart';

import '../../../../core/models/profile.dart';

abstract class MessagesRepository {
  Future<Either<Failure, Profile>> reloadMessageReceiver(String user);
  Future<Either<Failure, List<ChatMessage>>> getMessages(String receiver);
  Future<Either<Failure, List<Chat>?>> getMyMessages();
  Future<Either<Failure, bool>> deleteMessage(Message message);
  Future<Either<Failure, bool>> updateMessage(Message message);
  Future<Either<Failure, bool>> setSeen(String messageID);
}
