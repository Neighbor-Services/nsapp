class Dispute {
  final String? id;
  final String? raisedBy;
  final String? defendant;
  final String? appointment;
  final String reason;
  final String description;
  final String? status;
  final String? resolutionNotes;
  final String? createdAt;

  Dispute({
    this.id,
    this.raisedBy,
    this.defendant,
    this.appointment,
    required this.reason,
    required this.description,
    this.status,
    this.resolutionNotes,
    this.createdAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'],
      raisedBy: json['raised_by'],
      defendant: json['defendant'],
      appointment: json['appointment'],
      reason: json['reason'],
      description: json['description'],
      status: json['status'],
      resolutionNotes: json['resolution_notes'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (raisedBy != null) 'raised_by': raisedBy,
      if (defendant != null) 'defendant': defendant,
      if (appointment != null) 'appointment': appointment,
      'reason': reason,
      'description': description,
      if (status != null) 'status': status,
    };
  }
}
