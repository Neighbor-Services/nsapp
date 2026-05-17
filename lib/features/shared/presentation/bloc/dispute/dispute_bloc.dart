import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/features/shared/domain/usecase/create_dispute_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_disputes_use_case.dart';

part 'dispute_event.dart';
part 'dispute_state.dart';

class DisputeBloc extends HydratedBloc<DisputeEvent, DisputeState> {
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
      final results = await getMyDisputesUseCase(null);
      results.fold(
        (l) => emit(DisputeFailure(l.message)),
        (r) => emit(SuccessGetMyDisputesState(disputes: r)),
      );
    });
  }

  @override
  DisputeState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('disputes')) {
        final disputes = (json['disputes'] as List)
            .map((e) => Dispute.fromJson(e))
            .toList();
        return SuccessGetMyDisputesState(disputes: disputes);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(DisputeState state) {
    if (state is SuccessGetMyDisputesState) {
      return {
        'disputes': state.disputes.map((e) => e.toJson()).toList(),
      };
    }
    return null;
  }
}
