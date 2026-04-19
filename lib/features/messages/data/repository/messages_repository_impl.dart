import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/messages/data/datasource/remote/message_remote_datasource.dart';
import 'package:nsapp/features/messages/domain/repository/messages_repository.dart';

import '../../../../core/models/chat.dart';

import '../../../../core/services/hive_service.dart';

class MessagesRepositoryImpl extends MessagesRepository {
  final MessageRemoteDatasource messageRemoteDatasource;
  final HiveService hiveService;

  MessagesRepositoryImpl(this.messageRemoteDatasource, this.hiveService);

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String receiver,
  ) async {
    try {
      final cacheBox = hiveService.getBox(HiveService.messageBox);
      final cacheKey = 'messages_$receiver';
      final cached = cacheBox.get(cacheKey);
      
      List<ChatMessage> cachedMessages = [];
      String? afterDate;

      if (cached != null) {
        cachedMessages = List<ChatMessage>.from(cached);
        if (cachedMessages.isNotEmpty) {
          final lastMsg = cachedMessages.last.message;
          if (lastMsg != null && lastMsg.createdAt != null) {
            afterDate = lastMsg.createdAt!.toUtc().toIso8601String();
          }
        }
      }

      // 1. Fetch NEW messages from remote
      final results = await messageRemoteDatasource.getMessages(
        receiver: receiver,
        after: afterDate,
      );

      if (results != null) {
        // 2. Merge and Update Cache
        if (results.isNotEmpty) {
          cachedMessages.addAll(results);
          await cacheBox.put(cacheKey, cachedMessages);
        }
        return Right(cachedMessages);
      }

      // 3. Fallback to Cache if remote fetch strictly fails without throwing
      if (cachedMessages.isNotEmpty) {
        return Right(cachedMessages);
      }

      return Left(
        Failure(massege: "An error occurred and no cached data found"),
      );
    } catch (e) {
      // 4. Fallback to Cache on error
      final cached = hiveService
          .getBox(HiveService.messageBox)
          .get('messages_$receiver');
      if (cached != null) {
        return Right(List<ChatMessage>.from(cached));
      }
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getMyMessages() async {
    try {
      // 1. Fetch from remote
      final results = await messageRemoteDatasource.getMyMessages();

      if (results != null) {
        // 2. Update Cache
        await hiveService
            .getBox(HiveService.messageBox)
            .put('my_chats', results);
        return Right(results);
      }

      // 3. Fallback to Cache
      final cached = hiveService.getBox(HiveService.messageBox).get('my_chats');
      if (cached != null) {
        return Right(List<Chat>.from(cached));
      }

      return Left(
        Failure(massege: "An error occurred and no cached data found"),
      );
    } catch (e) {
      // 4. Fallback to Cache on error
      final cached = hiveService.getBox(HiveService.messageBox).get('my_chats');
      if (cached != null) {
        return Right(List<Chat>.from(cached));
      }
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, Profile>> reloadMessageReceiver(String user) async {
    try {
      final results = await messageRemoteDatasource.reloadMessageReceiver(user);
      if (results != null) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMessage(Message message) async {
    try {
      final results = await messageRemoteDatasource.deleteMessage(message);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> updateMessage(Message message) async {
    try {
      final results = await messageRemoteDatasource.updateMessage(message);
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }

  @override
  Future<Either<Failure, bool>> setSeen(String messageID) async {
    try {
      final results = await messageRemoteDatasource.setSeen(
        messageID: messageID,
      );
      if (results) {
        return Right(results);
      }
      return Left(Failure(massege: "An error occurred"));
    } catch (e) {
      return Left(Failure(massege: "An error occurred"));
    }
  }
}
