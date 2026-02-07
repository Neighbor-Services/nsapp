import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';

part 'customer.g.dart';

@HiveType(typeId: 11)
class Customer {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? stripeCustomerId;
  @HiveField(2)
  String? accountId;
  @HiveField(3)
  String? paymentMethod;
  @HiveField(4)
  String? ephemeralSecret;
  @HiveField(5)
  String? createdAt;
  @HiveField(6)
  String? updatedAt;

  Customer({
    this.id,
    this.stripeCustomerId,
    this.ephemeralSecret,
    this.createdAt,
    this.updatedAt,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stripeCustomerId = json['stripe_customer_id'];
    accountId = json['stripe_account_id'];
    paymentMethod = json['default_payment_method'];
    ephemeralSecret = json['ephemeral_secret'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['stripe_customer_id'] = stripeCustomerId;
    data['stripe_account_id'] = accountId;
    data['default_payment_method'] = paymentMethod;
    data['ephemeral_secret'] = ephemeralSecret;
    return data;
  }
}

@HiveType(typeId: 12)
class CustomerData {
  @HiveField(0)
  Customer? customer;
  @HiveField(1)
  Profile? user;

  CustomerData({this.customer, this.user});

  CustomerData.fromJson(Map<String, dynamic> json) {
    customer =
        (json['customer'] != null && json['customer'] is Map<String, dynamic>)
        ? Customer.fromJson(json['customer'])
        : null;
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
