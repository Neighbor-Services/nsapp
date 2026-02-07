import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? email;
  @HiveField(2)
  Password? password;
  @HiveField(3)
  bool? active;
  @HiveField(4)
  int? version;
  @HiveField(5)
  String? createdAt;
  @HiveField(6)
  String? updatedAt;
  @HiveField(7)
  bool? isSuperuser;
  @HiveField(8)
  String? lastLogin;

  User({
    this.id,
    this.email,
    this.password,
    this.active,
    this.version,
    this.createdAt,
    this.updatedAt,
    this.isSuperuser,
    this.lastLogin,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    active = json['active'];
    version = json['version'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isSuperuser = json['is_superuser'];
    lastLogin = json['last_login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    if (password != null) {
      data['password'] = password!.toJson();
    }
    data['active'] = active;
    data['version'] = version;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_superuser'] = isSuperuser;
    data['last_login'] = lastLogin;
    return data;
  }
}

@HiveType(typeId: 2)
class Password {
  @HiveField(0)
  final String? plainText;
  @HiveField(1)
  final String? hash;

  Password({this.hash, this.plainText});

  static Password fromJson(Map<String, dynamic> json) {
    return Password(plainText: "", hash: "");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    return data;
  }
}
