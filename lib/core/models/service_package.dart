import 'package:hive/hive.dart';

part 'service_package.g.dart';

@HiveType(typeId: 4)
class ServicePackage {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? profile;
  @HiveField(2)
  final String? name;
  @HiveField(3)
  final double? price;
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final int? deliveryTime; // Days
  @HiveField(6)
  final int? revisions;
  @HiveField(7)
  final List<String>? features;

  ServicePackage({
    this.id,
    this.profile,
    this.name,
    this.price,
    this.description,
    this.deliveryTime,
    this.revisions,
    this.features,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      id: json['id']?.toString(),
      profile: json['profile']?.toString(),
      name: json['name'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      description: json['description'],
      deliveryTime: json['delivery_time'],
      revisions: json['revisions'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'delivery_time': deliveryTime,
      'revisions': revisions,
      'features': features,
    };
  }
}
