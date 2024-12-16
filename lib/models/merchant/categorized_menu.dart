import 'package:nomnom/models/merchant/menu_item.dart';

class MenuResult {
  final List<MenuItem> popularItems;
  final List<CategorizedMenu> categorizedMenu;
  MenuResult({
    List<MenuItem>? popularItems,
    List<CategorizedMenu>? categorizedMenu,
  })  : popularItems = popularItems ?? [],
        categorizedMenu = categorizedMenu ?? [];
  factory MenuResult.fromJson(Map<String, dynamic> json) {
    return MenuResult(
      popularItems: (json['popular_items'] as List)
          .map((item) => MenuItem.fromJson(item))
          .toList(),
      categorizedMenu: json['group_data'].isEmpty
          ? []
          : (json['group_data'] as Map<String, dynamic>)
              .map((categoryName, itemsList) => MapEntry(
                    categoryName == '' ? "Unset" : categoryName,
                    CategorizedMenu.fromData(
                        categoryName, itemsList as List<dynamic>),
                  ))
              .values
              .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'popular_items': popularItems.map((item) => item.toJson()).toList(),
      'categorized_menu': categorizedMenu,
    };
  }
}

class CategorizedMenu {
  final String name;
  final List<MenuItem> items;

  const CategorizedMenu({required this.name, required this.items});
  factory CategorizedMenu.fromData(
      String categoryName, List<dynamic> itemsList) {
    // Extract the category name from the map keys
    return CategorizedMenu(
      name: categoryName,
      items: itemsList.map((item) => MenuItem.fromJson(item)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'category_name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() => '${toJson()}';
}
