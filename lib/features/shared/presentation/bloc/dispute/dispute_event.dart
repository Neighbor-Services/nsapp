part of 'dispute_bloc.dart';

abstract class DisputeEvent {}

class CreateDisputeEvent extends DisputeEvent {
  final Dispute dispute;
  CreateDisputeEvent({required this.dispute});
}

class GetMyDisputesEvent extends DisputeEvent {}
