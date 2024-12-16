import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

extension EXT on GeoPoint {
  String convertString() => "$latitude,$longitude";
  bool distanceIsWithin(Position pos, {required double kmRadius}) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371.0; // Radius of the earth in kilometers

    double dLat = (pos.latitude - latitude) * (pi / 180.0);
    double dLon = (pos.longitude - longitude) * (pi / 180.0);

    double a = pow(sin(dLat / 2), 2) +
        cos(latitude * (pi / 180.0)) *
            cos(pos.latitude * (pi / 180.0)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c <= kmRadius; // Distance in kilometers
  }

  double distanceBetween(Position pos) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371.0; // Radius of the earth in kilometers

    double dLat = (pos.latitude - latitude) * (pi / 180.0);
    double dLon = (pos.longitude - longitude) * (pi / 180.0);

    double a = pow(sin(dLat / 2), 2) +
        cos(latitude * (pi / 180.0)) *
            cos(pos.latitude * (pi / 180.0)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double distanceBetweenPoints(GeoPoint point) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371.0; // Radius of the earth in kilometers

    double dLat = (point.latitude - latitude) * (pi / 180.0);
    double dLon = (point.longitude - longitude) * (pi / 180.0);

    double a = pow(sin(dLat / 2), 2) +
        cos(latitude * (pi / 180.0)) *
            cos(point.latitude * (pi / 180.0)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double calculateDistance(GeoPoint point) {
    final double endLatitude = point.latitude;
    final double endLongitude = point.longitude;
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    double dLat = _degreesToRadians(endLatitude - latitude);
    double dLon = _degreesToRadians(endLongitude - longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(latitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String calculateETA(GeoPoint point) {
    const double upperSpeed = 50; //50 kph
    const double lowerSpeed = 30; //30 kph
    final double dstance = calculateDistance(point);
    final minETA = (dstance / upperSpeed) * 60; // Convert to minutes
    final maxETA = (dstance / lowerSpeed) * 60; // Convert to minutes
    // print("DISTANCE : $dstance");
    return '${minETA.round()}-${maxETA.round()} min${minETA > 1 ? "s" : ""}'; // ETA in hours
  }

  double calculateETAMinutes(GeoPoint point, {double speed = 20}) {
    final double dstance = calculateDistance(point);
    final eta = (dstance / speed) * 60;
    return eta;
  }
}

extension Convert on Position {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}
