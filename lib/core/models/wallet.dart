import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 22)
class Wallet {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? user;
  @HiveField(2)
  double? balance;
  @HiveField(3)
  String? currency;
  @HiveField(4)
  String? stripeConnectId;
  @HiveField(5)
  List<WalletTransaction>? transactions;
  @HiveField(6)
  List<PayoutRequest>? payoutRequests;

  Wallet({
    this.id,
    this.user,
    this.balance,
    this.currency,
    this.stripeConnectId,
    this.transactions,
    this.payoutRequests,
  });

  Wallet.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    user = json['user']?.toString();
    balance = double.tryParse(json['balance']?.toString() ?? '0.0');
    currency = json['currency'];
    stripeConnectId = json['stripe_connect_id'];
    if (json['transactions'] != null) {
      transactions = <WalletTransaction>[];
      json['transactions'].forEach((v) {
        transactions!.add(WalletTransaction.fromJson(v));
      });
    }
    if (json['payout_requests'] != null) {
      payoutRequests = <PayoutRequest>[];
      json['payout_requests'].forEach((v) {
        payoutRequests!.add(PayoutRequest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user'] = user;
    data['balance'] = balance;
    data['currency'] = currency;
    data['stripe_connect_id'] = stripeConnectId;
    // transactions/payouts are generally read-only in this context
    return data;
  }
}

@HiveType(typeId: 23)
class WalletTransaction {
  @HiveField(0)
  String? id;
  @HiveField(1)
  double? amount;
  @HiveField(2)
  String? transactionType;
  @HiveField(3)
  String? description;
  @HiveField(4)
  String? status;
  @HiveField(5)
  String? referenceId;
  @HiveField(6)
  DateTime? createdAt;

  WalletTransaction({
    this.id,
    this.amount,
    this.transactionType,
    this.description,
    this.status,
    this.referenceId,
    this.createdAt,
  });

  WalletTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    amount = double.tryParse(json['amount']?.toString() ?? '0.0');
    transactionType = json['transaction_type'];
    description = json['description'];
    status = json['status'];
    referenceId = json['reference_id'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
  }
}

@HiveType(typeId: 24)
class PayoutRequest {
  @HiveField(0)
  String? id;
  @HiveField(1)
  double? amount;
  @HiveField(2)
  String? status;
  @HiveField(3)
  DateTime? createdAt;

  PayoutRequest({this.id, this.amount, this.status, this.createdAt});

  PayoutRequest.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    amount = double.tryParse(json['amount']?.toString() ?? '0.0');
    status = json['status'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
  }
}
