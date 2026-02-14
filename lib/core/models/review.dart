import 'package:nsapp/core/models/profile.dart';

class Review {
  String? id;
  int? rating; // 1-5 star rating
  String? comment;
  String? provider; // User ID of provider being reviewed
  String? reviewer; // User ID of reviewer
  DateTime? createdAt;
  DateTime? updatedAt;

  Review({
    this.id,
    this.rating,
    this.comment,
    this.provider,
    this.reviewer,
    this.createdAt,
    this.updatedAt,
  });

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    rating = json['rating'];
    comment = json['comment'];
    provider = json['provider']?.toString();
    reviewer = json['reviewer']?.toString();
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['comment'] = comment;
    // Send as profile_id so backend can resolve it to user
    data['profile_id'] = provider;
    return data;
  }
}

class ReviewData {
  Review? review;
  Profile? from;
  Profile? to;

  ReviewData({this.review, this.from, this.to});

  ReviewData.fromJson(Map<String, dynamic> json) {
    review = json['review'] != null ? Review.fromJson(json['review']) : null;
    from = json['from'] != null ? Profile.fromJson(json['from']) : null;
    to = json['to'] != null ? Profile.fromJson(json['to']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (review != null) {
      data['review'] = review!.toJson();
    }
    if (from != null) {
      data['from'] = from!.toJson();
    }
    if (to != null) {
      data['to'] = to!.toJson();
    }
    return data;
  }
}
