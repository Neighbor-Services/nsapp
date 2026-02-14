import 'package:nsapp/core/models/profile.dart';

class About {
  String? id;
  String? userId;
  String? name;
  String? address;
  String? countryCode;
  String? specification;
  String? description;
  List? imageUrls;
  int? experienceYears;
  List? skills;
  String? education;
  List? languages;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? version;

  About({
    this.id,
    this.userId,
    this.name,
    this.address,
    this.countryCode,
    this.specification,
    this.description,
    this.imageUrls,
    this.experienceYears,
    this.skills,
    this.education,
    this.languages,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  About.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    address = json['address'];
    countryCode = json['country_code'];
    specification = json['specification'];
    description = json['description'];
    imageUrls = json['image_urls'];
    experienceYears = json['experience_years'];
    skills = json['skills'];
    education = json['education'];
    languages = json['languages'];
    createdAt = DateTime.parse(json['created_at']);
    updatedAt = DateTime.parse(json['updated_at']);
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['country_code'] = countryCode;
    data['specification'] = specification;
    data['description'] = description;
    data['experience_years'] = experienceYears;
    data['skills'] = skills;
    data['education'] = education;
    data['languages'] = languages;
    return data;
  }
}

class AboutData {
  About? about;
  Profile? user;

  AboutData({this.about, this.user});

  AboutData.fromJson(Map<String, dynamic> json) {
    about = json['about'] != null ? About.fromJson(json['about']) : null;
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (about != null) {
      data['about'] = about!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
