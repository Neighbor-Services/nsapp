import 'package:dio/dio.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/messages/data/datasource/remote/message_remote_datasource.dart';
import 'package:nsapp/core/constants/urls.dart';
import '../../../../../core/models/chat.dart';

class MessageRemoteDatasourceImpl extends MessageRemoteDatasource {
  @override
  Future<List<ChatMessage>?> getMessages({required String receiver}) async {
    try {
      List<ChatMessage> chats = [];
      final String token = await Helpers.getString("token");
      final response = await dio.get(
        '$baseMessagesUrl/chat/messages/?conversation=$receiver',
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        var data = (response.data is List)
            ? response.data
            : (response.data is Map ? response.data["results"] : []);
        if (data != null) {
          for (var chat in data) {
            chats.add(ChatMessage.fromJson(chat));
          }
        }
        return chats;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Chat>?> getMyMessages() async {
    try {
      List<Chat> chats = [];
      final String token = await Helpers.getString("token");
      final response = await dio.get(
        '$baseMessagesUrl/chat/conversations/',
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        var data = (response.data is List)
            ? response.data
            : (response.data is Map ? response.data["results"] : []);
        if (data != null) {
          for (var chat in data) {
            chats.add(Chat.fromJson(chat));
          }
        }
        return chats;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Profile?> reloadMessageReceiver(String user) async {
    try {
      final results = <String, dynamic>{};
      return Profile.fromJson(results);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteMessage(Message message) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateMessage(Message message) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setSeen({required String messageID}) async {
    try {
      final String token = await Helpers.getString("token");
      final response = await dio.post(
        '$baseMessagesUrl/chat/conversations/set_seen/',
        data: {"receiver_id": messageID},
        options: Options(headers: dioHeaders(token)),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
