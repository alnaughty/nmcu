import 'package:nomnom/models/merchant/variation.dart';

class Option {
  final int id;
  final int merchantId;
  final String name;
  final String description;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Variation> variations;
  Option({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.variations,
  });
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      merchantId: json['merchant_id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      variations: (json['variations'] as List)
          .map((variation) => Variation.fromJson(variation))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'variations': variations.map((v) => v.toJson()).toList(),
    };
  }

  @override
  String toString() => "${toJson()}";
}
