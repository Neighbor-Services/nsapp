import 'package:dio/dio.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/messages/data/datasource/remote/message_remote_datasource.dart';
import 'package:nsapp/core/constants/urls.dart';
import '../../../../../core/models/chat.dart';

class MessageRemoteDatasourceImpl extends MessageRemoteDatasource {
  final Dio _dio;

  MessageRemoteDatasourceImpl(this._dio);
  @override
  Future<List<ChatMessage>> getMessages({required String receiver, String? after}) async {
    try {
      List<ChatMessage> chats = [];
      final String token = await Helpers.getString("token");
      String url = '$baseMessagesUrl/chat/messages/?conversation=$receiver';
      if (after != null) {
        url += '&after=$after';
      }
      final response = await _dio.get(
        url,
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
      throw Exception('Failed');
    } catch (e) { rethrow; }
  }

  @override
  Future<List<Chat>> getMyMessages() async {
    try {
      List<Chat> chats = [];
      final String token = await Helpers.getString("token");
      final response = await _dio.get(
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
      throw Exception('Failed');
    } catch (e) { rethrow; }
  }

  @override
  Future<Profile> reloadMessageReceiver(String user) async {
    try {
      final token = await Helpers.getString("token");
      final response = await _dio.get(
        "$baseUrl/accounts/profile/?user=$user",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        if (response.data["providers"] is List &&
            (response.data["providers"] as List).isNotEmpty) {
          return Profile.fromJson(response.data["providers"][0]);
        }
      }
      throw Exception('Failed');
    } catch (e) { rethrow; }
  }

  @override
  Future<bool> deleteMessage(Message message) async {
    try {
      return true;
    } catch (e) { rethrow; }
  }

  @override
  Future<bool> updateMessage(Message message) async {
    try {
      return true;
    } catch (e) { rethrow; }
  }

  @override
  Future<bool> setSeen({required String messageID}) async {
    try {
      final String token = await Helpers.getString("token");
      final response = await _dio.post(
        '$baseMessagesUrl/chat/conversations/set_seen/',
        data: {"receiver_id": messageID},
        options: Options(headers: dioHeaders(token)),
      );
      return response.statusCode == 200;
    } catch (e) { rethrow; }
  }
}


