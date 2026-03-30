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

    return data;
  }
}
