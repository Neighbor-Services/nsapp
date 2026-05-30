import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 5)
class Message {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? chatRoomId;
  @HiveField(2)
  bool? withImage;
  @HiveField(3)
  bool? isCalender;
  @HiveField(4)
  bool? withImageAndText;
  @HiveField(5)
  String? message;
  @HiveField(6)
  DateTime? calenderDate;
  @HiveField(7)
  String? sender;
  @HiveField(8)
  String? receiver;
  @HiveField(9)
  String? mediaUrl;
  @HiveField(10)
  bool? read;
  @HiveField(11)
  DateTime? createdAt;
  @HiveField(12)
  DateTime? updatedAt;
  @HiveField(13)
  int? version;
  @HiveField(14)
  String? image;
  @HiveField(15)
  String? fileName;
  @HiveField(16)
  bool? isDelivered;
  Message({
    this.id,
    this.chatRoomId,
    this.withImage,
    this.isCalender,
    this.withImageAndText,
    this.message,
    this.calenderDate,
    this.sender,
    this.receiver,
    this.mediaUrl,
    this.read,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.image,
    this.fileName,
    this.isDelivered,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatRoomId = json['chat_room_id']?.toString();
    withImage = json['with_image'];
    isCalender = json['is_calender'];
    withImageAndText = json['with_image_and_text'];
    message = json['message'];
    
    // Unified calenderDate
    final cDate = json['calender_date'];
    calenderDate = cDate != null ? DateTime.parse(cDate.toString()) : null;

    sender = json['sender']?.toString();
    receiver = json['receiver']?.toString();
    mediaUrl = json['media_url'];
    read = json['read'] ?? json['is_seen'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at']).toUtc()
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at']).toUtc()
        : null;
    version = json['version'];
    image = json['image'];
    fileName = json['file_name'];
    isDelivered = json['is_delivered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_room_id'] = chatRoomId;
    data['receiver'] = receiver;
    data['with_image'] = withImage;
    data['is_calender'] = isCalender;
    data['with_image_and_text'] = withImageAndText;
    data['message'] = message;
    data['calender_date'] = calenderDate?.toUtc().toIso8601String();
    data["filename"] = fileName ?? "";
    data["image"] = image ?? "";
    data["is_delivered"] = isDelivered ?? false;
    data["read"] = read ?? false;

    return data;
  }

  Message copyWith({
    String? id,
    String? chatRoomId,
    bool? withImage,
    bool? isCalender,
    bool? withImageAndText,
    String? message,
    DateTime? calenderDate,
    String? sender,
    String? receiver,
    String? mediaUrl,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? image,
    String? fileName,
    bool? isDelivered,
  }) {
    return Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      withImage: withImage ?? this.withImage,
      isCalender: isCalender ?? this.isCalender,
      withImageAndText: withImageAndText ?? this.withImageAndText,
      message: message ?? this.message,
      calenderDate: calenderDate ?? this.calenderDate,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      image: image ?? this.image,
      fileName: fileName ?? this.fileName,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }
}


