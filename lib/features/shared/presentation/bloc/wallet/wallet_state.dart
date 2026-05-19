part of 'wallet_bloc.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletSuccess extends WalletState {}

class WalletFailure extends WalletState {
  final String? message;
  WalletFailure(this.message);
}

class SuccessGetMyWalletState extends WalletState {
  final Wallet? wallet;
  SuccessGetMyWalletState({this.wallet});
}

class SuccessRequestPayoutState extends WalletState {}

class SuccessGetStripeDashboardLinkState extends WalletState {
  final String dashboardUrl;
  SuccessGetStripeDashboardLinkState(this.dashboardUrl);
}

class SuccessConnectAccountState extends WalletState {
  final AccountLink accountLink;
  SuccessConnectAccountState(this.accountLink);
}
