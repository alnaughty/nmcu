import 'package:nomnom/models/cart/cart_item.dart';
import 'package:nomnom/models/merchant/merchant.dart';

class CartModel {
  final Merchant merchant;
  final List<CartItem> items;

  const CartModel({
    required this.merchant,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        merchant: Merchant.fromJson(json),
        items: json['items'] == null
            ? []
            : (json['items'] as List).map((e) => CartItem.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        "merchant": merchant.toJson(),
        "items": items.map((e) => e.toJson()).toList(),
      };
  @override
  String toString() => "${toJson()}";
}

class RawMerchant {
  final int id;
  final String name;

  const RawMerchant({required this.id, required this.name});

  factory RawMerchant.fromJson(Map<String, dynamic> json) => RawMerchant(
        id: json['merchant_id'],
        name: json['merchant_name'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  @override
  String toString() => "${toJson()}";
}
