class Report {
  String? id;
  String? reporterId;
  String? reportedUserId;
  String? resourceType;
  String? resourceId;
  String? reason;
  String? status;
  String? adminNote;
  DateTime? createdAt;
  DateTime? updatedAt;

  Report({
    this.id,
    this.reporterId,
    this.reportedUserId,
    this.resourceType,
    this.resourceId,
    this.reason,
    this.status,
    this.adminNote,
    this.createdAt,
    this.updatedAt,
  });

  Report.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reporterId = json['reporter'];
    reportedUserId = json['reported_user'];
    resourceType = json['resource_type'];
    resourceId = json['resource_id'];
    reason = json['reason'];
    status = json['status'];
    adminNote = json['admin_note'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reporter'] = reporterId;
    data['reported_user'] = reportedUserId;
    data['resource_type'] = resourceType;
    data['resource_id'] = resourceId;
    data['reason'] = reason;
    data['status'] = status;
    return data;
  }
}
