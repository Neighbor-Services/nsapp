import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/features/shared/domain/usecase/create_dispute_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_disputes_use_case.dart';

part 'dispute_event.dart';
part 'dispute_state.dart';

class DisputeBloc extends Bloc<DisputeEvent, DisputeState> {
  final CreateDisputeUseCase createDisputeUseCase;
  final GetMyDisputesUseCase getMyDisputesUseCase;

  DisputeBloc({
    required this.createDisputeUseCase,
    required this.getMyDisputesUseCase,
  }) : super(DisputeInitial()) {
    on<CreateDisputeEvent>((event, emit) async {
      emit(DisputeLoading());
      final results = await createDisputeUseCase(event.dispute);
      results.fold(
        (l) => emit(DisputeFailure(l.message)),
        (r) => emit(SuccessCreateDisputeState()),
      );
    });

    on<GetMyDisputesEvent>((event, emit) async {
      emit(DisputeLoading());
      // Assuming GetMyDisputesUseCase takes no arguments or a specific one
      // In SharedBloc it was taking event, which was likely GetMyDisputesEvent
      // Let's check the usecase signature
      final results = await getMyDisputesUseCase(null); // Or event if needed
      results.fold(
        (l) => emit(DisputeFailure(l.message)),
        (r) => emit(SuccessGetMyDisputesState(disputes: r)),
      );
    });
  }
}
