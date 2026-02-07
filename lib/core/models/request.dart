import 'package:hive/hive.dart';
import 'package:nsapp/core/models/services_model.dart';

part 'request.g.dart';

@HiveType(typeId: 17)
class Request {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? description;
  @HiveField(3)
  String? userId;
  @HiveField(4)
  Service? service;
  @HiveField(5)
  String? serviceID;
  @HiveField(6)
  bool? approved;
  @HiveField(7)
  String? address;
  @HiveField(8)
  DateTime? scheduledTime;
  @HiveField(9)
  double? longitude;
  @HiveField(10)
  double? latitude;
  @HiveField(11)
  bool? withImage;
  @HiveField(12)
  bool? done;
  @HiveField(13)
  String? imageUrl;
  @HiveField(14)
  String? approvedUser;
  @HiveField(15)
  DateTime? createdAt;
  @HiveField(16)
  DateTime? updatedAt;
  @HiveField(17)
  int? version;
  @HiveField(18)
  double? distance;
  @HiveField(19)
  String? status;
  @HiveField(20)
  int? proposalsCount;
  @HiveField(21)
  String? appointmentId;
  @HiveField(22)
  bool? isFunded;
  @HiveField(23)
  double? price;

  @HiveField(24)
  String? targetProviderId;

  Request({
    this.id,
    this.title,
    this.description,
    this.userId,
    this.service,
    this.approved,
    this.address,
    this.longitude,
    this.latitude,
    this.withImage,
    this.done,
    this.imageUrl,
    this.approvedUser,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.serviceID,
    this.scheduledTime,
    this.distance,
    this.status,
    this.proposalsCount,
    this.appointmentId,
    this.isFunded,
    this.price,
    this.targetProviderId,
  });

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    userId = json['user_id'] ?? json['user']?.toString();
    String? sName = json['catalog_service_name'] ?? json['service_name'];

    if (json['service'] is Map<String, dynamic>) {
      service = Service.fromJson(json['service']);
      serviceID = service?.id;
    } else {
      if (json['service'] is String) {
        serviceID = json['service'];
      } else {
        serviceID = json['catalog_service']?.toString();
      }

      if (sName != null) {
        service = Service(id: serviceID, name: sName);
      }
    }
    approved = json['approved'];
    address = json['address'];
    longitude = json['longitude'] != null
        ? double.tryParse(json['longitude'].toString())
        : null;
    latitude = json['latitude'] != null
        ? double.tryParse(json['latitude'].toString())
        : null;
    distance = json['distance'] != null
        ? double.tryParse(json['distance'].toString())
        : null;
    withImage = json['with_image'];
    done = json['done'] ?? (json['status'] == 'DONE');
    status = json['status'] ?? (done == true ? 'DONE' : 'OPEN');
    proposalsCount = json['proposals_count'];
    imageUrl = json['image_url'] ?? json['image'];
    // Handle approved_user which can be a String (UUID) or a Map (Profile)
    if (json['approved_user'] is Map<String, dynamic>) {
      approvedUser =
          (json['approved_user']['user'] is Map<String, dynamic>
                  ? json['approved_user']['user']['id']
                  : json['approved_user']['user'])
              ?.toString();
      approvedUser ??= json['approved_user']['id']?.toString();
    } else {
      approvedUser = json['approved_user']?.toString();
    }

    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null;
    scheduledTime = json['scheduled_time'] != null
        ? DateTime.tryParse(json['scheduled_time'].toString())
        : null;
    version = json['version'];
    appointmentId = json['appointment_id'];
    isFunded = json['is_funded'];
    price = json['price'] != null
        ? double.tryParse(json['price'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['service'] = (serviceID == null || serviceID == "") ? null : serviceID;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['with_image'] = withImage ?? false;
    data['price'] = price;
    data['status'] = (done ?? false) ? 'DONE' : 'OPEN';
    data['scheduled_time'] = scheduledTime?.toIso8601String();
    if (targetProviderId != null) {
      data['target_provider'] = targetProviderId;
    }
    return data;
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;

    // Only send service if it's a valid UUID string
    if (serviceID != null && serviceID!.isNotEmpty) {
      data['service'] = serviceID;
    } else {
      data['service'] = null;
    }

    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['with_image'] = withImage ?? false;
    data['price'] = price;
    data['scheduled_time'] = scheduledTime?.toIso8601String();
    data['status'] = status ?? ((done ?? false) ? 'DONE' : 'OPEN');
    return data;
  }
}
