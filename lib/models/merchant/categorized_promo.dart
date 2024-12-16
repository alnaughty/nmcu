import 'package:nomnom/models/merchant/promo.dart';

class CategorizedPromoModel {
  final int promoType;
  final String promoTypeString;
  final List<PromoModel> promos;

  CategorizedPromoModel({
    required this.promoType,
    required this.promoTypeString,
    required this.promos,
  });
}
