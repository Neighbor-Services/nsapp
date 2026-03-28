import 'package:hive/hive.dart';
import 'package:nsapp/core/models/request.dart';

part 'acceptance.g.dart';

@HiveType(typeId: 16)
class Acceptance {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? providerId;
  @HiveField(2)
  bool? isApproved;
  @HiveField(3)
  Request? request;
  @HiveField(4)
  String? createdAt;
  @HiveField(5)
  String? updatedAt;
  @HiveField(6)
  int? version;

  Acceptance({
    this.id,
    this.providerId,
    this.isApproved,
    this.request,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  Acceptance.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    providerId = json['provider']?.toString();
    isApproved = json['is_approved'];
    
    // Check multiple potential keys for the request object
    final requestJson = json['request'] ?? json['service_request'] ?? json['service_request_id'];
    
    request = requestJson != null && requestJson is Map<String, dynamic>
        ? Request.fromJson(requestJson)
        : (requestJson != null
              ? Request(id: requestJson.toString())
              : null);
              
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider'] = providerId;
    data['is_approved'] = isApproved;
    if (request != null) {
      data['request'] = request!.id; // backend expects request ID
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['version'] = version;
    return data;
  }
}
