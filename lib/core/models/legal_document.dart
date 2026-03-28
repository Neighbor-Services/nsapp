class LegalDocument {
  final String id;
  final String docType;
  final String title;
  final String content;
  final String version;
  final String updatedAt;

  LegalDocument({
    required this.id,
    required this.docType,
    required this.title,
    required this.content,
    required this.version,
    required this.updatedAt,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'] ?? '',
      docType: json['doc_type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      version: json['version'] ?? '1.0',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doc_type': docType,
      'title': title,
      'content': content,
      'version': version,
      'updated_at': updatedAt,
    };
  }
}
