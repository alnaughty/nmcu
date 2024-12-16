import 'package:nomnom/models/merchant/menu_item.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/merchant/option.dart';

class MenuItemDetails extends MenuItem {
  final List<Option> options;
  final Merchant merchant;
  final RawCategory category;
  MenuItemDetails(
      {required super.subCat,
      required super.mainCat,
      required super.id,
      required super.pid,
      required super.name,
      required super.rate,
      required super.type,
      required super.unit,
      required super.price,
      required super.sizeId,
      required super.isAmount,
      required super.photoUrl,
      required super.basePrice,
      required super.createdAt,
      required super.isPercent,
      required super.isPopular,
      required super.orderType,
      required super.updatedAt,
      required super.categoryId,
      required super.description,
      required super.merchantId,
      required super.typeConfig,
      required super.isAvailable,
      required super.extraRequired,
      required super.quantityLimit,
      required super.subCategoryId,
      required super.preparationDays,
      required super.preparationTime,
      required this.options,
      required this.category,
      required this.merchant,
      required super.classificationId});

  factory MenuItemDetails.fromJson(Map<String, dynamic> json) {
    final List _options = json['options'] ?? [];
    return MenuItemDetails(
        mainCat: json['main_category'],
        subCat: json['sub_category'],
        id: json['id'],
        pid: json['pid'],
        name: json['name'],
        rate: json['rate'].toDouble(),
        type: json['type'],
        unit: json['unit'],
        price: json['price'].toDouble(),
        sizeId: json['size_id'],
        isAmount: json['is_amount'],
        photoUrl: json['photo_url'] ??
            "https://back.nomnomdelivery.com/images/no_image_placeholder.jpg",
        basePrice: json['base_price'].toDouble(),
        createdAt: DateTime.parse(json['created_at']),
        isPercent: json['is_percent'],
        isPopular: json['is_popular'] == 1,
        orderType: json['order_type'],
        updatedAt: DateTime.parse(json['updated_at']),
        categoryId: json['category_id'],
        description: json['description'],
        merchantId: json['merchant_id'],
        typeConfig: json['type_config'],
        isAvailable: json['is_available'] == 1,
        extraRequired: json['extra_required'],
        quantityLimit: json['quantity_limit'],
        subCategoryId: json['sub_category_id'],
        preparationDays: json['preparation_days'],
        preparationTime: json['preparation_time'],
        classificationId: json['classification_id'],
        category: RawCategory.fromJson(json['category']),
        merchant: Merchant.fromJson(json['merchant']),
        options: _options.map((e) => Option.fromJson(e)).toList());
  }
  Map<String, dynamic> toMap() {
    final body = toJson();
    body.addAll({
      'options': options.map((e) => e.toJson()),
      'merchant': merchant.toJson(),
    });
    return body;
  }

  @override
  String toString() => "${toJson()}";
}
