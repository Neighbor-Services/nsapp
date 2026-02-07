import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';

part 'notification.g.dart';

@HiveType(typeId: 20)
class Notification {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? notificationType;
  @HiveField(2)
  String? title;
  @HiveField(3)
  String? message;
  @HiveField(4)
  Map<String, dynamic>? data;
  @HiveField(5)
  bool? isRead;
  @HiveField(6)
  DateTime? createdAt;

  Notification({
    this.id,
    this.notificationType,
    this.title,
    this.message,
    this.data,
    this.isRead,
    this.createdAt,
  });

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    notificationType = json['notification_type'];
    title = json['title'];
    message = json['message'];
    data = json['data'];
    isRead = json['is_read'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['notification_type'] = notificationType;
    data['title'] = title;
    data['message'] = message;
    data['data'] = this.data;
    data['is_read'] = isRead;
    return data;
  }
}

@HiveType(typeId: 21)
class NotificationData {
  @HiveField(0)
  Notification? notification;
  @HiveField(1)
  Profile? from; // Keep for legacy if needed, but backend doesn't provide natively yet in the same way
  @HiveField(2)
  Profile? to;

  NotificationData({this.notification, this.from, this.to});

  NotificationData.fromJson(Map<String, dynamic> json) {
    notification = json['notification'] != null
        ? Notification.fromJson(json['notification'])
        : (json['id'] != null ? Notification.fromJson(json) : null);
    from = json['from'] != null
        ? Profile.fromJson(json['from'])
        : (json['sender_profile'] != null
              ? Profile.fromJson(json['sender_profile'])
              : null);
    to = json['to'] != null ? Profile.fromJson(json['to']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notification != null) {
      data['notification'] = notification!.toJson();
    }
    if (from != null) {
      data['from'] = from!.toJson();
    }
    if (to != null) {
      data['to'] = to!.toJson();
    }
    return data;
  }
}
