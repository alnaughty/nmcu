import 'package:nomnom/models/geocoder/coordinates.dart';

class GeoAddress {
  /// The geographic coordinates.
  final Coordinates? coordinates;

  /// The formatted address with all lines.
  final String? addressLine;

  /// The localized country name of the address.
  final String? countryName;

  /// The country code of the address.
  final String? countryCode;

  /// The feature name of the address.
  final String? featureName;

  /// The postal code.
  final String? postalCode;

  /// The administrative area name of the address
  final String? adminArea;

  /// The administrative area code of the address
  final String? adminAreaCode;

  /// The sub-administrative area name of the address
  final String? subAdminArea;

  /// The locality of the address
  final String? locality;

  /// The sub-locality of the address
  final String? subLocality;

  /// The thoroughfare name of the address
  final String? thoroughfare;

  /// The sub-thoroughfare name of the address
  final String? subThoroughfare;

  GeoAddress({
    this.coordinates,
    this.addressLine,
    this.countryName,
    this.countryCode,
    this.featureName,
    this.postalCode,
    this.adminArea,
    this.adminAreaCode,
    this.subAdminArea,
    this.locality,
    this.subLocality,
    this.thoroughfare,
    this.subThoroughfare,
  });

  /// Creates an address from a map containing its properties.
  GeoAddress.fromMap(Map map)
      : coordinates = Coordinates.fromMap(map["coordinates"]),
        addressLine = map["addressLine"],
        countryName = map["countryName"],
        countryCode = map["countryCode"],
        featureName = map["featureName"],
        postalCode = map["postalCode"],
        locality = map["locality"],
        subLocality = map["subLocality"],
        adminArea = map["adminArea"],
        adminAreaCode = map["adminAreaCode"],
        subAdminArea = map["subAdminArea"],
        thoroughfare = map["thoroughfare"],
        subThoroughfare = map["subThoroughfare"];

  /// Creates a map from the address properties.
  Map toMap() => {
        "coordinates": coordinates?.toMap(),
        "addressLine": addressLine,
        "countryName": countryName,
        "countryCode": countryCode,
        "featureName": featureName,
        "postalCode": postalCode,
        "locality": locality,
        "subLocality": subLocality,
        "adminArea": adminArea,
        "adminAreaCode": adminAreaCode,
        "subAdminArea": subAdminArea,
        "thoroughfare": thoroughfare,
        "subThoroughfare": subThoroughfare,
      };

  @override
  String toString() => "${toMap()}";
}
