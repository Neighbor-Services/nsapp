import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/domain/usecase/get_legal_document_use_case.dart';
export 'legal_event.dart';
export 'legal_state.dart';
import 'legal_event.dart';
import 'legal_state.dart';

class LegalBloc extends Bloc<LegalEvent, LegalState> {
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
}
