part of 'wallet_bloc.dart';

abstract class WalletEvent {}

class GetMyWalletEvent extends WalletEvent {}

class RequestPayoutEvent extends WalletEvent {
  final double amount;
  RequestPayoutEvent({required this.amount});
}

class GetStripeDashboardLinkEvent extends WalletEvent {}

class CreateConnectAccountEvent extends WalletEvent {}
