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
  DateTime? calenderStartDate;
  @HiveField(7)
  DateTime? calenderEndDate;
  @HiveField(8)
  DateTime? calenderDate;
  @HiveField(9)
  String? sender;
  @HiveField(10)
  String? receiver;
  @HiveField(11)
  String? mediaUrl;
  @HiveField(12)
  bool? read;
  @HiveField(13)
  DateTime? createdAt;
  @HiveField(14)
  DateTime? updatedAt;
  @HiveField(15)
  int? version;
  @HiveField(16)
  String? image;
  @HiveField(17)
  String? fileName;
  Message({
    this.id,
    this.chatRoomId,
    this.withImage,
    this.isCalender,
    this.withImageAndText,
    this.message,
    this.calenderStartDate,
    this.calenderEndDate,
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
    calenderStartDate = json['calender_start_date'] != null
        ? DateTime.parse(json['calender_start_date'])
        : null;
    calenderEndDate = json['calender_end_date'] != null
        ? DateTime.parse(json['calender_end_date'])
        : null;
    calenderDate = json['calender_date'] != null
        ? DateTime.parse(json['calender_date'])
        : null;
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
    data['calender_start_date'] = calenderStartDate?.toUtc().toIso8601String();
    data['calender_end_date'] = calenderEndDate?.toUtc().toIso8601String();
    data['calender_date'] = calenderDate?.toUtc().toIso8601String();
    data["filename"] = fileName ?? "";
    data["image"] = image ?? "";

    return data;
  }
}
