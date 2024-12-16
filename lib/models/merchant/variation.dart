class Variation {
  final int id;
  final int optionId;
  final String title;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Variation({
    required this.id,
    required this.optionId,
    required this.title,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      id: json['id'],
      optionId: json['option_id'],
      title: json['title'],
      price: double.tryParse(json['price'].toString()) ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_id': optionId,
      'title': title,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
