abstract class LegalEvent {}

class GetLegalDocumentEvent extends LegalEvent {
  final String docType;
  GetLegalDocumentEvent({required this.docType});
}
