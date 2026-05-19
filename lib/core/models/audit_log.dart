class AuditLog {
  final String? id;
  final String? action;
  final String? resourceType;
  final String? resourceId;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final DateTime? createdAt;
  final String? userEmail;

  AuditLog({
    this.id,
    this.action,
    this.resourceType,
    this.resourceId,
    this.details,
    this.ipAddress,
    this.createdAt,
    this.userEmail,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      action: json['action'],
      resourceType: json['resource_type'],
      resourceId: json['resource_id'],
      details: json['details'],
      ipAddress: json['ip_address'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      userEmail: json['user_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'resource_type': resourceType,
      'resource_id': resourceId,
      'details': details,
      'ip_address': ipAddress,
      'created_at': createdAt?.toIso8601String(),
      'user_email': userEmail,
    };
  }
}


