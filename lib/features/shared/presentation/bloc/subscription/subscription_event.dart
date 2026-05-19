import 'package:flutter/material.dart';

abstract class SubscriptionEvent {}

class CheckUserSubscriptionEvent extends SubscriptionEvent {}

class DeleteUserSubscriptionEvent extends SubscriptionEvent {}

class GetSubscriptionPlansEvent extends SubscriptionEvent {}

class MakeSubscriptionEvent extends SubscriptionEvent {
  final BuildContext context;
  final String planId;

  MakeSubscriptionEvent({required this.planId, required this.context});
}
