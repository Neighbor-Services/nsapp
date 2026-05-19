

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nsapp/features/shared/domain/usecase/get_legal_document_use_case.dart';
import 'package:nsapp/core/models/legal_document.dart';

export 'legal_event.dart';
export 'legal_state.dart';
import 'legal_event.dart';
import 'legal_state.dart';


class LegalBloc extends HydratedBloc<LegalEvent, LegalState> {

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
}
