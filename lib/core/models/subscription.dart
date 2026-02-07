import 'package:nsapp/core/models/profile.dart';

class Subscription {
  final String? id;
  final String? user;
  final String? stripeSubscriptionId;
  final String? stripePlanId;
  final DateTime? nextPayment;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subscription({
    this.id,
    this.user,
    this.stripeSubscriptionId,
    this.stripePlanId,
    this.nextPayment,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json["id"],
      user: json["user"],
      stripeSubscriptionId: json["stripe_subscription_id"],
      stripePlanId: json["stripe_plan_id"],
      nextPayment: json["next_payment"] != null
          ? DateTime.parse(json["next_payment"])
          : null,
      isActive: json["is_active"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user": user,
      "stripe_subscription_id": stripeSubscriptionId,
      "stripe_plan_id": stripePlanId,
      "next_payment": nextPayment?.toIso8601String(),
      "is_active": isActive,
    };
  }
}

class SubscriptionData {
  final Subscription? subscription;
  final Profile? profile;

  SubscriptionData({this.subscription, this.profile});

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      subscription: json["subscription"] != null
          ? Subscription.fromJson(json["subscription"])
          : null,
      profile: json["profile"] != null
          ? Profile.fromJson(json["profile"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "subscription": subscription?.toJson(),
      "profile": profile?.toJson(),
    };
  }
}
