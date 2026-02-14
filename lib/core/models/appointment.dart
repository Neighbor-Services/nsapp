import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';

part 'appointment.g.dart';

@HiveType(typeId: 6)
class Appointment {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? userId;
  @HiveField(3)
  String? description;
  @HiveField(4)
  DateTime? startDate;
  @HiveField(5)
  DateTime? endDate;
  @HiveField(6)
  String? chatID;
  @HiveField(7)
  DateTime? appointmentDate;
  @HiveField(8)
  bool? fromChat;
  @HiveField(9)
  String? fromUser;
  @HiveField(10)
  DateTime? createdAt;
  @HiveField(11)
  DateTime? updatedAt;
  @HiveField(12)
  int? version;
  @HiveField(13)
  String? status;
  @HiveField(14)
  String? providerId;
  @HiveField(15)
  DateTime? scheduledTime;
  @HiveField(16)
  bool? isConsultation;
  @HiveField(17)
  String? consultationChannel;
  @HiveField(18)
  bool? isFunded;
  @HiveField(19)
  String? paymentIntentId;
  @HiveField(20)
  double? totalPrice;
  @HiveField(21)
  String? proposalId;

  DateTime? get effectiveDate => startDate ?? scheduledTime ?? appointmentDate;

  Appointment({
    this.id,
    this.title,
    this.userId,
    this.description,
    this.startDate,
    this.endDate,
    this.appointmentDate,
    this.chatID,
    this.fromChat,
    this.fromUser,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.status,
    this.providerId,
    this.scheduledTime,
    this.isConsultation,
    this.consultationChannel,
    this.isFunded,
    this.paymentIntentId,
    this.totalPrice,
    this.proposalId,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    userId = json['seeker']?.toString(); // backend uses 'seeker'
    description = json['description'];
    startDate = json['start_date'] != null
        ? DateTime.parse(json['start_date'])
        : null;
    endDate = json['end_date'] != null
        ? DateTime.parse(json['end_date'])
        : null;
    appointmentDate = json['appointment_date'] != null
        ? DateTime.parse(json['appointment_date'])
        : null;
    fromChat =
        json['from_chat']; // check if backend has this, if not, it will be null
    fromUser = json['from_user']?.toString();
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null;
    version = json['version'];
    status = json['status'];
    providerId = json['provider']?.toString();
    scheduledTime = json['scheduled_time'] != null
        ? DateTime.parse(json['scheduled_time'])
        : null;
    isConsultation = json['is_consultation'];
    consultationChannel = json['consultation_channel'];
    isFunded = json['is_funded'];
    paymentIntentId = json['payment_intent_id'];
    totalPrice = json['total_price'] != null
        ? double.tryParse(json['total_price'].toString())
        : null;
    proposalId = json['proposal']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (startDate != null) data['start_date'] = startDate?.toIso8601String();
    if (endDate != null) data['end_date'] = endDate?.toIso8601String();
    if (appointmentDate != null) {
      data['appointment_date'] = appointmentDate?.toIso8601String();
    }
    if (status != null) data['status'] = status;
    if (providerId != null) data['provider'] = providerId;
    if (scheduledTime != null) {
      data['scheduled_time'] = scheduledTime?.toIso8601String();
    }
    data['is_consultation'] = isConsultation ?? false;
    data['is_funded'] = isFunded ?? false;
    if (paymentIntentId != null) {
      data['payment_intent_id'] = paymentIntentId;
    }
    data['total_price'] = totalPrice ?? 0.00;
    if (userId != null) data['seeker'] = userId;
    if (proposalId != null) data['proposal'] = proposalId;
    return data;
  }
}

@HiveType(typeId: 7)
class AppointmentData {
  @HiveField(0)
  Appointment? appointment;
  @HiveField(1)
  Profile? user;

  AppointmentData({this.appointment, this.user});

  AppointmentData.fromJson(Map<String, dynamic> json) {
    appointment = json['appointment'] != null
        ? Appointment.fromJson(json['appointment'])
        : null;
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (appointment != null) {
      data['appointment'] = appointment!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
