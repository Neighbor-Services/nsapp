<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/domain/usecase/get_legal_document_use_case.dart';
=======
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nsapp/features/shared/domain/usecase/get_legal_document_use_case.dart';
import 'package:nsapp/core/models/legal_document.dart';
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
export 'legal_event.dart';
export 'legal_state.dart';
import 'legal_event.dart';
import 'legal_state.dart';

<<<<<<< HEAD
class LegalBloc extends Bloc<LegalEvent, LegalState> {
=======
class LegalBloc extends HydratedBloc<LegalEvent, LegalState> {
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
  final GetLegalDocumentUseCase getLegalDocumentUseCase;

  LegalBloc({required this.getLegalDocumentUseCase}) : super(LegalInitial()) {
    on<GetLegalDocumentEvent>((event, emit) async {
      emit(LegalLoading());
      final results = await getLegalDocumentUseCase(event.docType);
      results.fold(
        (l) => emit(LegalFailure(l.message)),
        (r) => emit(SuccessGetLegalDocumentState(documents: r)),
      );
    });
  }
<<<<<<< HEAD
=======

  @override
  LegalState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('documents')) {
        final docs = (json['documents'] as List)
            .map((e) => LegalDocument.fromJson(e))
            .toList();
        return SuccessGetLegalDocumentState(documents: docs);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(LegalState state) {
    if (state is SuccessGetLegalDocumentState) {
      return {
        'documents': state.documents.map((e) => e.toJson()).toList(),
      };
    }
    return null;
  }
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
}
