<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
=======
import 'package:hydrated_bloc/hydrated_bloc.dart';
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/shared/domain/usecase/get_subscription_plans_use_case.dart';
export 'subscription_event.dart';
export 'subscription_state.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

<<<<<<< HEAD
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
=======
class SubscriptionBloc extends HydratedBloc<SubscriptionEvent, SubscriptionState> {
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
  final GetSubscriptionPlansUseCase getSubscriptionPlansUseCase;

  SubscriptionBloc({required this.getSubscriptionPlansUseCase})
      : super(SubscriptionInitial()) {
    on<CheckUserSubscriptionEvent>((event, emit) async {
      final bool isValid = await Helpers.userHasTheValidSubscription();
      emit(ValidUserSubscriptionState(isValid: isValid));
    });

    on<DeleteUserSubscriptionEvent>((event, emit) async {
      emit(SubscriptionLoading());
      final bool success = await Helpers.deleteUserSubscriptionDetails();
      if (success) {
        emit(SuccessDeleteUserSubscriptionState());
      } else {
        emit(SubscriptionFailure("Failed to delete subscription details"));
      }
    });

    on<GetSubscriptionPlansEvent>((event, emit) async {
      emit(SubscriptionLoading());
      final results = await getSubscriptionPlansUseCase();
      results.fold(
        (l) => emit(SubscriptionFailure(l.message)),
        (r) => emit(SuccessGetSubscriptionPlansState(plans: r)),
      );
    });

    on<MakeSubscriptionEvent>((event, emit) async {
      emit(SubscriptionLoading());
      final success = await Payment.createSubscription(event.context, event.planId);
      if (success) {
        emit(SuccessMakeSubscriptionState());
      } else {
        emit(SubscriptionFailure("Failed to create subscription"));
      }
    });
  }
<<<<<<< HEAD
=======

  @override
  SubscriptionState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('isValid')) {
        return ValidUserSubscriptionState(isValid: json['isValid']);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(SubscriptionState state) {
    if (state is ValidUserSubscriptionState) {
      return {'isValid': state.isValid};
    }
    return null;
  }
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
}
