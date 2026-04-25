import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request.dart';

part 'appointment.g.dart';

@HiveType(typeId: 6)
class Appointment {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? seekerId; // Unified: renamed from userId to match backend 'seeker'
  @HiveField(3)
  String? description;
  @HiveField(7)
  DateTime? appointmentDate;
  @HiveField(6)
  String? chatID;
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
  @HiveField(22)
  Request? serviceRequest;
  @HiveField(23)
  String? secretCode;

  DateTime? get effectiveDate => appointmentDate;

  Appointment({
    this.id,
    this.title,
    this.seekerId,
    this.description,
    this.appointmentDate,
    this.chatID,
    this.fromChat,
    this.fromUser,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.status,
    this.providerId,
    this.isConsultation,
    this.consultationChannel,
    this.isFunded,
    this.paymentIntentId,
    this.totalPrice,
    this.proposalId,
    this.serviceRequest,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    title = json['title'];
    // Unified seekerId mapping
    seekerId = (json['seeker'] ?? json['seeker_id'] ?? json['userId'] ?? json['user_id'])?.toString();
    description = json['description'];
    
    // Unified appointment_date
    final apptD = json['appointment_date'] ?? json['appointmentDate'];
    appointmentDate = apptD != null ? DateTime.parse(apptD.toString()) : null;

    chatID = json['chatID'];
    fromChat = json['from_chat'] ?? json['fromChat'];
    fromUser = (json['from_user'] ?? json['fromUser'])?.toString();
    
    final createdA = json['created_at'] ?? json['createdAt'];
    createdAt = createdA != null ? DateTime.parse(createdA.toString()) : null;
    
    final updatedA = json['updated_at'] ?? json['updatedAt'];
    updatedAt = updatedA != null ? DateTime.parse(updatedA.toString()) : null;
    
    version = json['version'];
    status = json['status'];
    providerId = (json['provider'] ?? json['provider_id'] ?? json['providerId'])?.toString();
    
    isConsultation = json['is_consultation'] ?? json['isConsultation'];
    consultationChannel = json['consultation_channel'] ?? json['consultationChannel'];
    isFunded = json['is_funded'] ?? json['isFunded'];
    paymentIntentId = json['payment_intent_id'] ?? json['paymentIntentId'];
    
    totalPrice = json['total_price'] != null
        ? double.tryParse(json['total_price'].toString())
        : (json['totalPrice'] != null ? double.tryParse(json['totalPrice'].toString()) : null);
        
    proposalId = (json['proposal'] ?? json['proposal_id'] ?? json['proposalId'])?.toString();
    
    if (json['service_request_details'] != null) {
      serviceRequest = Request.fromJson(json['service_request_details']);
    }
    
    secretCode = json['secret_code'] ?? json['secretCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null && id!.isNotEmpty) data['id'] = id;
    if (title != null) data['title'] = title;
    if (seekerId != null) data['seeker'] = seekerId; 
    if (description != null) data['description'] = description;
    if (appointmentDate != null) {
      data['appointment_date'] = appointmentDate!.toIso8601String();
    }
    if (status != null) data['status'] = status;
    if (providerId != null) data['provider'] = providerId;
    if (isConsultation != null) data['is_consultation'] = isConsultation;
    if (consultationChannel != null) {
      data['consultation_channel'] = consultationChannel;
    }
    if (isFunded != null) data['is_funded'] = isFunded;
    if (paymentIntentId != null) data['payment_intent_id'] = paymentIntentId;
    if (totalPrice != null) data['total_price'] = totalPrice;
    if (proposalId != null) data['proposal'] = proposalId;
    if (secretCode != null) data['secret_code'] = secretCode;
    return data;

  }
}

@HiveType(typeId: 7)
class AppointmentData {
  @HiveField(0)
  Appointment? appointment;
  @HiveField(1)
  Profile? user;
  @HiveField(2)
  String? role;

  AppointmentData({this.appointment, this.user, this.role});

  AppointmentData.fromJson(Map<String, dynamic> json) {
    appointment = json['appointment'] != null
        ? Appointment.fromJson(json['appointment'])
        : null;
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (appointment != null) {
      data['appointment'] = appointment!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (role != null) {
      data['role'] = role;
    }
    return data;
  }
}
