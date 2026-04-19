import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/profile.dart';

import '../../../../../core/models/chat.dart';

abstract class MessageRemoteDatasource {
  Future<Profile?> reloadMessageReceiver(String user);
  Future<List<ChatMessage>?> getMessages({required String receiver, String? after});
  Future<List<Chat>?> getMyMessages();
  Future<bool> updateMessage(Message message);
  Future<bool> deleteMessage(Message message);
  Future<bool> setSeen({required String messageID});
}
