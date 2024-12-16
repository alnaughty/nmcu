import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/user/user_address.dart';

class CurrentAddress {
  final GeoPoint coordinates;
  final String addressLine,
      city,
      countryCode,
      locality,
      country,
      street,
      barangay,
      state,
      region;
  const CurrentAddress({
    required this.addressLine,
    required this.city,
    required this.coordinates,
    required this.locality,
    required this.country,
    required this.countryCode,
    required this.barangay,
    required this.region,
    required this.state,
    required this.street,
  });

  factory CurrentAddress.fromBackend(Map<String, dynamic> json) =>
      CurrentAddress(
        street: json['street'] ?? "",
        state: json['state'] ?? "",
        barangay: json['barangay'] ?? "",
        region: json['region'] ?? "",
        addressLine: json['address'],
        city: json['city'].toString().capitalizeWords(),
        coordinates: json['coordinates'].toString().toGeopoint(),
        locality: json['state'].toString().capitalizeWords(),
        countryCode: json['country_code'] ?? "PH",
        country: json['country'].toString().capitalizeWords(),
      );

  UserAddress toUserAddress() => UserAddress(
      addressLine: addressLine,
      city: city,
      coordinates: coordinates,
      locality: locality,
      countryCode: countryCode,
      id: 0,
      title: 'Current Location',
      country: country,
      barangay: barangay,
      region: region,
      state: state,
      street: street);
}
