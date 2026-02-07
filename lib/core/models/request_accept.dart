class RequestAccept {
  final String uid;
  final String serviceRequestId;
  final String? proposalId;

  RequestAccept({
    required this.serviceRequestId,
    required this.uid,
    this.proposalId,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "service_request_id": serviceRequestId,
      "proposal_id": proposalId,
    };
  }
}
