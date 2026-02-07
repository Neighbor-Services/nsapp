import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request.dart';

part 'request_data.g.dart';

@HiveType(typeId: 13)
class RequestData {
  @HiveField(0)
  Request? request;
  @HiveField(1)
  Profile? user;
  @HiveField(2)
  Profile? approvedUser;

  RequestData({this.request, this.user, this.approvedUser});

  RequestData.fromJson(Map<String, dynamic> json) {
    request = Request.fromJson(json);

    // Check for user_profile first (new structure)
    if (json['user_profile'] != null) {
      user = Profile.fromJson(json['user_profile']);
    }
    // Fallback/Legacy check
    else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      user = Profile.fromJson(json['user']);
    }

    approvedUser = json['approved_user'] != null
        ? Profile.fromJson(json['approved_user'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (request != null) {
      data['request'] = request!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (approvedUser != null) {
      data['approved_user'] = approvedUser!.toJson();
    }
    return data;
  }
}
