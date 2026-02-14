import 'package:hive/hive.dart';
import 'package:nsapp/core/models/user.dart';
import 'package:nsapp/core/models/portfolio_item.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/core/models/performance_badge.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class Profile {
  @HiveField(0)
  String? id;
  @HiveField(1)
  User? user;
  @HiveField(2)
  String? firstName;
  @HiveField(3)
  String? lastName;
  @HiveField(4)
  DateTime? dateOfBirth;
  @HiveField(5)
  String? service;
  @HiveField(6)
  String? country;
  @HiveField(7)
  String? state;
  @HiveField(8)
  String? zipCode;
  @HiveField(9)
  String? gender;
  @HiveField(10)
  String? countryCode;
  @HiveField(11)
  String? phone;
  @HiveField(12)
  String? city;
  @HiveField(13)
  List? ratings;
  @HiveField(14)
  String? address;
  @HiveField(15)
  String? rating;
  @HiveField(16)
  String? deviceToken;
  @HiveField(17)
  String? profilePictureUrl;
  @HiveField(18)
  String? userType;
  @HiveField(19)
  String? longitude;
  @HiveField(20)
  String? latitude;
  @HiveField(21)
  DateTime? createdAt;
  @HiveField(22)
  DateTime? updatedAt;
  @HiveField(23)
  int? version;
  @HiveField(24)
  double? averageRating;
  @HiveField(25)
  int? totalReviews;
  @HiveField(26)
  List<PortfolioItem>? portfolioItems;
  @HiveField(27)
  List<ServicePackage>? servicePackages;
  @HiveField(28)
  String? bio;
  @HiveField(29)
  String? catalogServiceId;
  @HiveField(30)
  String? catalogServiceName;
  @HiveField(31)
  bool? isIdentityVerified;
  @HiveField(32)
  String? subscriptionTier;
  @HiveField(33)
  List<PerformanceBadge>? performanceBadges;

  Profile({
    this.id,
    this.user,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.service,
    this.country,
    this.state,
    this.zipCode,
    this.gender,
    this.countryCode,
    this.phone,
    this.city,
    this.ratings,
    this.address,
    this.rating,
    this.deviceToken,
    this.profilePictureUrl,
    this.userType,
    this.longitude,
    this.latitude,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.averageRating,
    this.totalReviews,
    this.bio,
    this.catalogServiceId,
    this.isIdentityVerified,
    this.subscriptionTier,
    this.performanceBadges,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    user = json['user'] != null && json['user'] is Map
        ? User.fromJson(Map<String, dynamic>.from(json['user']))
        : null;
    firstName = json['first_name'];
    lastName = json['last_name'];
    dateOfBirth = json['date_of_birth'] != null
        ? DateTime.parse(json['date_of_birth'])
        : null;
    service = json['service']?.toString();
    country = json['country'];
    state = json['state'];
    zipCode = json['zip_code'];
    gender = json['gender'];
    countryCode = json['country_code'];
    phone = json['phone'];
    city = json['city'];
    ratings = json['ratings'];
    address = json['address'];
    rating = json['rating']?.toString();
    deviceToken = json['device_token'];
    profilePictureUrl = json['profile_picture_url'] ?? json['profile_picture'];
    userType = json['user_type'];
    longitude = json['longitude']?.toString();
    latitude = json['latitude']?.toString();
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null;
    version = json['version'];
    averageRating = json['average_rating'] != null
        ? double.tryParse(json['average_rating'].toString())
        : 0.0;
    totalReviews = json['total_reviews'];
    // Map backend average_rating to existing rating string for compatibility
    if (json['average_rating'] != null) {
      rating = json['average_rating'].toString();
    }
    if (json['portfolio_items'] != null) {
      portfolioItems = <PortfolioItem>[];
      json['portfolio_items'].forEach((v) {
        portfolioItems!.add(PortfolioItem.fromJson(v));
      });
    }
    if (json['service_packages'] != null) {
      servicePackages = (json['service_packages'] as List)
          .map((i) => ServicePackage.fromJson(i))
          .toList();
    }
    bio = json['bio'];
    catalogServiceId = json['catalog_service']?.toString();
    isIdentityVerified = json['is_identity_verified'] ?? false;
    subscriptionTier = json['subscription_tier'];
    if (json['performance_badges'] != null) {
      performanceBadges = <PerformanceBadge>[];
      json['performance_badges'].forEach((v) {
        performanceBadges!.add(PerformanceBadge.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    if (dateOfBirth != null) {
      data['date_of_birth'] =
          "${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}";
    }
    data['catalog_service'] =
        (catalogServiceId != null && catalogServiceId!.isNotEmpty)
        ? catalogServiceId
        : null;
    data['service'] = service;
    data['country'] = country;
    data['state'] = state;
    data['zip_code'] = zipCode;
    data['gender'] = gender?.toUpperCase();
    data['country_code'] = countryCode;
    data['phone'] = phone;
    data['city'] = city;
    data['address'] = address;
    data['user_type'] = userType?.toUpperCase();
    data['longitude'] = (longitude != null && longitude!.isNotEmpty)
        ? longitude
        : null;
    data['latitude'] = (latitude != null && latitude!.isNotEmpty)
        ? latitude
        : null;
    data['average_rating'] = averageRating;
    data['total_reviews'] = totalReviews;
    data['bio'] = bio;
    data['subscription_tier'] = subscriptionTier ?? 'NONE';
    if (performanceBadges != null) {
      data['performance_badges'] = performanceBadges!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}
