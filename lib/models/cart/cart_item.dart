import 'dart:convert';

import 'package:nomnom/models/merchant/menu_item.dart';

class CartItem {
  final int menuId, cartID, quantityLimit;
  bool isSelected;
  int quantity;
  final double subtotal;
  final OrderType orderType;
  final bool isAvailable;
  final String menuName, photoUrl, description;
  final RawCategory category;
  final RawCategory classification;
  final List additionalData;
  CartItem({
    required this.cartID,
    required this.isSelected,
    required this.menuId,
    required this.menuName,
    required this.photoUrl,
    required this.quantity,
    required this.quantityLimit,
    required this.subtotal,
    required this.orderType,
    required this.isAvailable,
    required this.description,
    required this.category,
    required this.classification,
    required this.additionalData,
  });
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      additionalData: jsonDecode(json['additional_data']) as List,
      classification: RawCategory.fromJson(json['classification']),
      category: RawCategory.fromJson(json['category']),
      cartID: json['id'],
      orderType: OrderType.fromJson(json['order_type']),
      isSelected: false,
      menuId: json['menu_item_id'],
      description: json['description'],
      menuName: json['name'],
      photoUrl: json['photo_url'],
      quantity: json['quantity'],
      quantityLimit: json['quantity_limit'],
      isAvailable: json['is_available'] == 1,
      subtotal: json['price'].toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'cartID': cartID,
      'isSelected': isSelected,
      'menuId': menuId,
      'menuName': menuName,
      'photoUrl': photoUrl,
      'quantity': quantity,
      'quantityLimit': quantityLimit,
      'subtotal': subtotal,
      'order_type': orderType.toJson(),
    };
  }
}
