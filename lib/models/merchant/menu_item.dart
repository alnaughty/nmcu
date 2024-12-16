class OrderItem {
  final int id;
  final int orderId;
  final int menuItemId;
  final int sizeId;
  final String name;
  final int quantityLimit;
  final OrderType orderType;
  final String? size;
  final Classification classification;
  final String description;
  final Category category;
  final RawCategory? subCategory;
  final int isPopular;
  final int isAvailable;
  final int isAmount;
  final int isPercent;
  final double price;
  final double rate;
  final double basePrice;
  final String unit;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int orderTypeValue;
  final double amount;
  final String specialInstructions;
  final List<Addon> addons;
  final int merchantId;
  final int customerId;
  final String merchantName;
  final int cartId;
  final int preparationTime;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.sizeId,
    required this.name,
    required this.quantityLimit,
    required this.orderType,
    this.size,
    required this.classification,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.isPopular,
    required this.isAvailable,
    required this.isAmount,
    required this.isPercent,
    required this.price,
    required this.rate,
    required this.basePrice,
    required this.unit,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.orderTypeValue,
    required this.amount,
    required this.specialInstructions,
    required this.addons,
    required this.merchantId,
    required this.customerId,
    required this.merchantName,
    required this.cartId,
    required this.preparationTime,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    print("ORDER TYPE:  ${json['order_type']} ${json['order_id']}");
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      menuItemId: json['menu_item_id'],
      sizeId: json['size_id'],
      name: json['name'],
      quantityLimit: json['quantity_limit'],
      orderType: json['order_type'] is String
          ? OrderType(id: 1, text: "Same day")
          : OrderType.fromJson(json['order_type']),
      size: json['size'],
      classification: Classification.fromJson(json['classification']),
      description: json['description'],
      category: Category.fromJson(json['category']),
      subCategory: json['sub_category'] == null
          ? null
          : RawCategory.fromJson(json['sub_category']),
      isPopular: json['is_popular'],
      isAvailable: json['is_available'],
      isAmount: json['is_amount'],
      isPercent: json['is_percent'],
      price: json['price'].toDouble(),
      rate: json['rate'].toDouble(),
      basePrice: json['base_price'].toDouble(),
      unit: json['unit'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      orderTypeValue: json['order_type_value'],
      amount: json['amount'].toDouble(),
      specialInstructions: json['special_instructions'],
      addons: (json['addons'] as List)
          .map((addon) => Addon.fromJson(addon))
          .toList(),
      merchantId: json['merchant_id'],
      customerId: json['customer_id'],
      merchantName: json['merchant_name'],
      cartId: json['cart_id'],
      preparationTime: json['preparation_time'],
    );
  }
}

class OrderType {
  final int id;
  final String text;

  OrderType({required this.id, required this.text});

  factory OrderType.fromJson(Map<String, dynamic> json) {
    try {
      return OrderType(
        id: json['id'],
        text: json['text'],
      );
    } catch (e) {
      return OrderType(id: 1, text: "Same Day");
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": text,
      };

  @override
  String toString() => "${toJson()}";
}

class Classification {
  final int id;
  final String name;

  Classification({
    required this.id,
    required this.name,
  });

  factory Classification.fromJson(Map<String, dynamic> json) {
    return Classification(
      id: json['id'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Category {
  final int id;
  final String name;
  final MenuItem menuItem;

  Category({required this.id, required this.name, required this.menuItem});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      menuItem: MenuItem.fromJson(json['menu_item']),
    );
  }
}

class RawCategory {
  final int id;
  final String name;

  RawCategory({
    required this.id,
    required this.name,
  });

  factory RawCategory.fromJson(Map<String, dynamic> json) {
    return RawCategory(
      id: json['id'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class MenuItem {
  final int id;
  final String? mainCat;
  final String? subCat;
  final String pid;
  final String name;
  final double rate;
  final int type;
  final String unit;
  final double price;
  final int sizeId;
  final int isAmount;
  final String photoUrl;
  final double basePrice;
  final DateTime createdAt;
  final int isPercent;
  bool isPopular;
  final int orderType;
  final DateTime updatedAt;
  final int categoryId;
  final String description;
  final int merchantId;
  final String typeConfig;
  bool isAvailable;
  final int extraRequired;
  final int quantityLimit;
  final int subCategoryId;
  final int preparationDays;
  final int preparationTime;
  final int classificationId;

  MenuItem({
    required this.subCat,
    required this.mainCat,
    required this.id,
    required this.pid,
    required this.name,
    required this.rate,
    required this.type,
    required this.unit,
    required this.price,
    required this.sizeId,
    required this.isAmount,
    required this.photoUrl,
    required this.basePrice,
    required this.createdAt,
    required this.isPercent,
    required this.isPopular,
    required this.orderType,
    required this.updatedAt,
    required this.categoryId,
    required this.description,
    required this.merchantId,
    required this.typeConfig,
    required this.isAvailable,
    required this.extraRequired,
    required this.quantityLimit,
    required this.subCategoryId,
    required this.preparationDays,
    required this.preparationTime,
    required this.classificationId,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
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
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pid': pid,
      'name': name,
      'rate': rate,
      'type': type,
      'unit': unit,
      'price': price,
      'size_id': sizeId,
      'is_amount': isAmount,
      'photo_url': photoUrl,
      'base_price': basePrice,
      'created_at': createdAt.toIso8601String(),
      'is_percent': isPercent,
      'is_popular': isPopular ? 1 : 0,
      'order_type': orderType,
      'updated_at': updatedAt.toIso8601String(),
      'category_id': categoryId,
      'description': description,
      'merchant_id': merchantId,
      'type_config': typeConfig,
      'is_available': isAvailable ? 1 : 0,
      'extra_required': extraRequired,
      'quantity_limit': quantityLimit,
      'sub_category_id': subCategoryId,
      'preparation_days': preparationDays,
      'preparation_time': preparationTime,
      'classification_id': classificationId,
    };
  }
}

class Addon {
  final MenuItem? product;
  final int quantity;
  final double totalPrice;
  final int menuItemId;

  Addon({
    this.product,
    required this.quantity,
    required this.totalPrice,
    required this.menuItemId,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      product:
          json['product'] == null ? null : MenuItem.fromJson(json['product']),
      quantity: json['quantity'],
      totalPrice: json['total_price'].toDouble(),
      menuItemId: json['menu_item_id'],
    );
  }
}
