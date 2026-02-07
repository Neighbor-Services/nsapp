import 'package:hive/hive.dart';
import 'package:nsapp/core/models/profile.dart';

part 'favorite.g.dart';

@HiveType(typeId: 15)
class Favorite {
  @HiveField(0)
  String? id;
  @HiveField(1)
  Profile? user;
  @HiveField(2)
  Profile? favoriteUser;
  @HiveField(3)
  DateTime? createdAt;
  @HiveField(4)
  int? version;

  Favorite({
    this.id,
    this.user,
    this.favoriteUser,
    this.createdAt,
    this.version,
  });

  Favorite.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // We expect user to be an ID string from backend for Favorites
    user = json['user'] is Map<String, dynamic>
        ? Profile.fromJson(json['user'])
        : (json['user'] != null ? Profile(id: json['user'].toString()) : null);
    favoriteUser =
        json['favorite_user'] != null &&
            json['favorite_user'] is Map<String, dynamic>
        ? Profile.fromJson(json['favorite_user'])
        : null;
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.id; // Backend expects ID for create
    }
    if (favoriteUser != null) {
      data['provider'] = favoriteUser!
          .id; // Backend FavoriteViewSet expects "provider" for create in addToFavorite but actually the model uses favorite_user.
      // Wait, let's check SeekerRemoteDatasourceImpl.addToFavorite
    }
    return data;
  }
}
