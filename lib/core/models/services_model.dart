import 'package:hive/hive.dart';

part 'services_model.g.dart';

@HiveType(typeId: 19)
class Category {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? description;
  @HiveField(3)
  String? image;
  @HiveField(4)
  DateTime? createdAt;
  @HiveField(5)
  DateTime? updatedAt;

  Category({
    this.id,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;
    return data;
  }
}

@HiveType(typeId: 18)
class Service {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? categoryId;
  @HiveField(2)
  String? name;
  @HiveField(3)
  String? description;
  @HiveField(4)
  double? basePrice;
  @HiveField(5)
  DateTime? createdAt;
  @HiveField(6)
  DateTime? updatedAt;
  @HiveField(7)
  String? categoryName;

  Service({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.basePrice,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category'];
    categoryName = json['category_name'];
    name = json['name'];
    description = json['description'];
    basePrice = json['base_price'] != null
        ? double.tryParse(json['base_price'].toString())
        : null;
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = categoryId;
    data['name'] = name;
    data['description'] = description;
    data['base_price'] = basePrice;
    return data;
  }
}
