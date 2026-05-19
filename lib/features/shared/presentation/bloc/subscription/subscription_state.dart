import 'package:nsapp/core/models/subscription_plan.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionFailure extends SubscriptionState {
  final String? message;
  SubscriptionFailure(this.message);
}

class ValidUserSubscriptionState extends SubscriptionState {
  final bool isValid;
  ValidUserSubscriptionState({required this.isValid});
}

class SuccessDeleteUserSubscriptionState extends SubscriptionState {}

class SuccessGetSubscriptionPlansState extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  SuccessGetSubscriptionPlansState({required this.plans});
}

class SuccessMakeSubscriptionState extends SubscriptionState {}
