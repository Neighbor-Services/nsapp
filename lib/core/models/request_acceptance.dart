import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';

import 'acceptance.dart';

part 'request_acceptance.g.dart';

@HiveType(typeId: 14)
class RequestAcceptance {
  @HiveField(0)
  Acceptance? acceptance;
  @HiveField(1)
  Profile? provider;
  @HiveField(2)
  Profile? user;

  RequestAcceptance({this.acceptance, this.provider, this.user});

  RequestAcceptance.fromJson(Map<String, dynamic> json) {
    acceptance = json['acceptance'] != null
        ? Acceptance.fromJson(json['acceptance'])
        : null;
    provider = json['provider'] != null
        ? Profile.fromJson(json['provider'])
        : null;
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (acceptance != null) {
      data['acceptance'] = acceptance!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
