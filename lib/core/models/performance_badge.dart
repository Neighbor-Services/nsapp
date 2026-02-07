import 'package:hive/hive.dart';

part 'performance_badge.g.dart'; // Run: flutter pub run build_runner build --delete-conflicting-outputs

@HiveType(typeId: 100)
class PerformanceBadge {
  @HiveField(0)
  final String? name;
  @HiveField(1)
  final String? iconType;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final DateTime? awardedAt;

  PerformanceBadge({
    this.name,
    this.iconType,
    this.description,
    this.awardedAt,
  });

  factory PerformanceBadge.fromJson(Map<String, dynamic> json) {
    return PerformanceBadge(
      name: json['name'],
      iconType: json['icon_type'],
      description: json['description'],
      awardedAt: json['awarded_at'] != null
          ? DateTime.parse(json['awarded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon_type': iconType,
      'description': description,
      'awarded_at': awardedAt?.toIso8601String(),
    };
  }
}
