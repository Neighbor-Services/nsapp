part of 'dispute_bloc.dart';

abstract class DisputeState {}

class DisputeInitial extends DisputeState {}

class DisputeLoading extends DisputeState {}

class DisputeSuccess extends DisputeState {}

class DisputeFailure extends DisputeState {
  final String? message;
  DisputeFailure(this.message);
}

class SuccessGetMyDisputesState extends DisputeState {
  final List<Dispute> disputes;
  SuccessGetMyDisputesState({required this.disputes});
}

class SuccessCreateDisputeState extends DisputeState {}
