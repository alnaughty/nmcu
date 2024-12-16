import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/models/geocoder/coordinates.dart';
import 'package:nomnom/models/geocoder/geoaddress.dart';

abstract class Geocoding {
  /// Search corresponding addresses from given [coordinates].
  Future<List<GeoAddress>> findAddressesFromCoordinates(
      Coordinates coordinates);

  /// Search corresponding addresses from given [coordinates] from [geopoint].
  Future<List<GeoAddress>> findAddressesFromGeoPoint(GeoPoint coordinates);

  /// Search for addresses that matches que given [address] query.
  Future<List<GeoAddress>> findAddressesFromQuery(String address);
}
