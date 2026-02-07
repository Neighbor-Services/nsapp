import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';

import 'message.dart';

part 'chat.g.dart';

@HiveType(typeId: 8)
class Chat {
  @HiveField(0)
  ChatData? chat;
  @HiveField(1)
  Profile? me;
  @HiveField(2)
  Profile? other;

  Chat({this.chat, this.me, this.other});

  Chat.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('chat')) {
      chat = json['chat'] != null ? ChatData.fromJson(json['chat']) : null;
      me = json['me'] != null ? Profile.fromJson(json['me']) : null;
      other = json['other'] != null ? Profile.fromJson(json['other']) : null;
    } else {
      // Fallback for flat structure
      chat = ChatData.fromJson(json);
      // Profiles might be missing or under different keys in flat structure
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chat != null) {
      data['chat'] = chat!.toJson();
    }
    if (me != null) {
      data['me'] = me!.toJson();
    }
    if (other != null) {
      data['other'] = other!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 9)
class ChatData {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? chatRoom;
  @HiveField(2)
  String? user1;
  @HiveField(3)
  String? user2;
  @HiveField(4)
  String? createdAt;
  @HiveField(5)
  String? updatedAt;
  @HiveField(6)
  Message? lastMessage;
  @HiveField(7)
  String? version;
  @HiveField(8)
  int? unreadCount;

  ChatData({
    this.id,
    this.chatRoom,
    this.user1,
    this.user2,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.version,
    this.unreadCount,
  });

  ChatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatRoom = json['chat_room'];
    user1 = json['user1'];
    user2 = json['user2'];
    unreadCount = json['unread_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    lastMessage = json['last_message'] != null
        ? Message.fromJson(json['last_message'])
        : null;
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['chat_room'] = chatRoom;
    data['user1'] = user1;
    data['user2'] = user2;
    data['unread_count'] = unreadCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (lastMessage != null) {
      data['last_message'] = lastMessage!.toJson();
    }
    data['version'] = version;
    return data;
  }
}

@HiveType(typeId: 10)
class ChatMessage {
  @HiveField(0)
  Message? message;
  @HiveField(1)
  Profile? sender;
  @HiveField(2)
  Profile? receiver;

  ChatMessage({this.message, this.sender, this.receiver});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('message')) {
      message = json['message'] != null
          ? Message.fromJson(json['message'])
          : null;
      sender = json['sender'] != null ? Profile.fromJson(json['sender']) : null;
      receiver = json['receiver'] != null
          ? Profile.fromJson(json['receiver'])
          : null;
    } else {
      // Fallback for flat structure
      message = Message.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (message != null) {
      data['message'] = message!.toJson();
    }
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    if (receiver != null) {
      data['receiver'] = receiver!.toJson();
    }
    return data;
  }
}
