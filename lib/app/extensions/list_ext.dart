import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/models/merchant/categorized_promo.dart';
import 'package:nomnom/models/merchant/promo.dart';
import 'package:nomnom/models/user/rider_firestore.dart';

extension PARSER on List<PromoModel> {
  String mapPromoTypeToString(int promoType) {
    switch (promoType) {
      case 1:
        return "Free Delivery";
      case 2:
        return "Order Discount";
      case 3:
        return "Total Order Discount";
      default:
        return "Unknown Type";
    }
  }

  List<CategorizedPromoModel> categorize() {
    final Map<int, List<PromoModel>> groupedPromos = {};
    // Group promos by promoType
    for (var promo in this) {
      if (!groupedPromos.containsKey(promo.promoType)) {
        groupedPromos[promo.promoType] = [];
      }
      groupedPromos[promo.promoType]!.add(promo);
    }
    return groupedPromos.entries.map((entry) {
      final promoType = entry.key;
      return CategorizedPromoModel(
        promoType: promoType,
        promoTypeString: mapPromoTypeToString(promoType),
        promos: entry.value,
      );
    }).toList();
  }
}

extension TAKER on List<RiderFirestore> {
  // Radius of Earth in kilometers
  static const double _radius = 6371.0; // In kilometers
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _radius * c; // Distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  Future<List<RiderOpinion>> getTop3({required GeoPoint storePoint}) async {
    // Calculate the distance for each rider and sort them
    var sortedRiders = map((rider) {
      var distance = _haversine(storePoint.latitude, storePoint.longitude,
          rider.coordinates.latitude, rider.coordinates.longitude);
      // {'rider': rider, 'distance': distance}
      return RiderOpinion(distance: distance, riderId: rider.riderId);
    }).toList();
    // Sort riders by distance
    sortedRiders.sort((a, b) => a.distance.compareTo(b.distance));

    // Take the top 3 nearest riders
    final List<RiderOpinion> top3Riders =
        sortedRiders.take(3).map((e) => e).toList();

    return top3Riders;
  }
}
