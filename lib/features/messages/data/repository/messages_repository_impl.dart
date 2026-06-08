import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/messages/data/datasource/remote/message_remote_datasource.dart';
import 'package:nsapp/features/messages/domain/repository/messages_repository.dart';

import '../../../../core/models/chat.dart';
import '../../../../core/services/hive_service.dart';
import 'package:nsapp/core/helpers/error_handler.dart';

class MessagesRepositoryImpl extends MessagesRepository {
  final MessageRemoteDatasource messageRemoteDatasource;
  final HiveService hiveService;

  MessagesRepositoryImpl(this.messageRemoteDatasource, this.hiveService);

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String receiver, {
    String? before,
  }) async {
    try {
      final cacheBox = hiveService.getBox(HiveService.messageBox);
      final cacheKey = 'messages_$receiver';
      final cached = cacheBox.get(cacheKey);
      
      List<ChatMessage> cachedMessages = [];
      if (cached != null) {
        cachedMessages = List<ChatMessage>.from(cached);
      }

      String? afterDate;
      // If we are NOT fetching older messages, fetch only messages AFTER our latest one
      if (before == null && cachedMessages.isNotEmpty) {
        final lastMsg = cachedMessages.last.message;
        if (lastMsg != null && lastMsg.createdAt != null) {
          afterDate = lastMsg.createdAt!.toUtc().toIso8601String();
        }
      }

      final results = await messageRemoteDatasource.getMessages(
        receiver: receiver,
        after: afterDate,
        before: before,
      );

      if (results.isNotEmpty) {
        if (before != null) {
          // Fetching older messages: prepend them
          cachedMessages.insertAll(0, results);
        } else {
          // Fetching newer messages: append them
          cachedMessages.addAll(results);
        }
        // Deduplicate just in case (based on message ID)
        final seenIds = <String>{};
        cachedMessages = cachedMessages.where((m) {
          final id = m.message?.id;
          if (id == null) return true;
          return seenIds.add(id);
        }).toList();
        
        await cacheBox.put(cacheKey, cachedMessages);
      }
      return Right(cachedMessages);
    } catch (e) {
      final cached = hiveService
          .getBox(HiveService.messageBox)
          .get('messages_$receiver');
      if (cached != null) {
        return Right(List<ChatMessage>.from(cached));
      }
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getMyMessages() async {
    try {
      // 1. Fetch from remote
      final results = await messageRemoteDatasource.getMyMessages();

      // 2. Update Cache
      await hiveService
          .getBox(HiveService.messageBox)
          .put('my_chats', results);
      return Right(results);
    } catch (e) {
      // 3. Fallback to Cache on error
      final cached = hiveService.getBox(HiveService.messageBox).get('my_chats');
      if (cached != null) {
        return Right(List<Chat>.from(cached));
      }
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Profile>> reloadMessageReceiver(String user) async {
    try {
      final results = await messageRemoteDatasource.reloadMessageReceiver(user);
      return Right(results);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMessage(Message message) async {
    try {
      final results = await messageRemoteDatasource.deleteMessage(message);
      if (results) {
        return Right(results);
      }
      return Left(Failure(message: "An error occurred"));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateMessage(Message message) async {
    try {
      final results = await messageRemoteDatasource.updateMessage(message);
      if (results) {
        return Right(results);
      }
      return Left(Failure(message: "An error occurred"));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
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
      return Left(Failure(message: "An error occurred"));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> blockChat(String conversationId, String userId) async {
    try {
      final results = await messageRemoteDatasource.blockChat(
        conversationId: conversationId,
        userId: userId,
      );
      if (results) {
        return Right(results);
      }
      return Left(Failure(message: "An error occurred"));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> unblockChat(String conversationId, String userId) async {
    try {
      final results = await messageRemoteDatasource.unblockChat(
        conversationId: conversationId,
        userId: userId,
      );
      if (results) {
        return Right(results);
      }
      return Left(Failure(message: "An error occurred"));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}



