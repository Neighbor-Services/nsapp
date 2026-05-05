import 'package:nsapp/core/models/legal_document.dart';

abstract class LegalState {}

class LegalInitial extends LegalState {}

class LegalLoading extends LegalState {}

class LegalFailure extends LegalState {
  final String? message;
  LegalFailure(this.message);
}

class SuccessGetLegalDocumentState extends LegalState {
  final List<LegalDocument> documents;
  SuccessGetLegalDocumentState({required this.documents});
}
