import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/legal_document.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class GetLegalDocumentUseCase {
  final SharedRepository repository;

  GetLegalDocumentUseCase(this.repository);

  Future<Either<Failure, List<LegalDocument>>> call(String docType) async {
    return await repository.getLegalDocument(docType);
  }
}
