import 'package:hive/hive.dart';

part 'portfolio_item.g.dart';

@HiveType(typeId: 3)
class PortfolioItem {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String imageUrl;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final List<String>? tags;

  PortfolioItem({
    required this.id,
    required this.imageUrl,
    this.description,
    this.tags,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'],
      imageUrl: json['image_url'] ?? json['image'],
      description: json['description'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'description': description,
      'tags': tags,
    };
  }
}
