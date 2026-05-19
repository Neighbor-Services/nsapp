import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/account_link.dart';
import 'package:nsapp/core/models/wallet.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_wallet_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/request_payout_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_stripe_dashboard_link_use_case.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetMyWalletUseCase getMyWalletUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;
  final GetStripeDashboardLinkUseCase getStripeDashboardLinkUseCase;

  WalletBloc({
    required this.getMyWalletUseCase,
    required this.requestPayoutUseCase,
    required this.getStripeDashboardLinkUseCase,
  }) : super(WalletInitial()) {
    on<GetMyWalletEvent>((event, emit) async {
      emit(WalletLoading());
      final results = await getMyWalletUseCase();
      results.fold(
        (l) => emit(WalletFailure(l.message)),
        (r) => emit(SuccessGetMyWalletState(wallet: r)),
      );
    });

    on<RequestPayoutEvent>((event, emit) async {
      emit(WalletLoading());
      final results = await requestPayoutUseCase(event.amount);
      results.fold(
        (l) => emit(WalletFailure(l.message)),
        (r) => emit(SuccessRequestPayoutState()),
      );
    });

    on<GetStripeDashboardLinkEvent>((event, emit) async {
      emit(WalletLoading());
      final results = await getStripeDashboardLinkUseCase();
      results.fold(
        (l) => emit(WalletFailure(l.message)),
        (r) => emit(SuccessGetStripeDashboardLinkState(r)),
      );
    });

    on<CreateConnectAccountEvent>((event, emit) async {
      emit(WalletLoading());
      final account = await Payment.createAccountLink();
      if (account != null) {
        emit(SuccessConnectAccountState(account));
      } else {
        emit(WalletFailure("Failed to create connect account link"));
      }
    });
  }
}
