// import 'package:able_me/view_models/notifiers/current_address_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/user/current_address.dart';

class UserAddress extends CurrentAddress {
  final int id;
  final String title;
  UserAddress(
      {required super.addressLine,
      required super.city,
      required super.coordinates,
      required super.locality,
      required super.countryCode,
      required this.id,
      required this.title,
      required super.country,
      required super.barangay,
      required super.region,
      required super.state,
      required super.street});
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    final List<double> c = json['coordinates']
        .toString()
        .split(',')
        .map((e) => double.parse(e))
        .toList();
    return UserAddress(
      barangay: json['barangay'] ?? "",
      state: json['state'],
      street: json['street'] ?? "",
      region: json['region'] ?? "",
      addressLine: json['address'],
      city: json['city'],
      coordinates: GeoPoint(c.first, c.last),
      locality: json['state'],
      countryCode: json['country'],
      id: json['id'],
      title: json['title'] ?? "UNSET",
      country: json['country'].toString().capitalize(),
    );
  }
  UserAddress copyWith({
    String? addressLine,
    String? city,
    GeoPoint? coordinates,
    String? locality,
    String? countryCode,
    int? id,
    String? title,
    String? country,
    String? barangay,
    String? region,
    String? state,
    String? street,
  }) {
    return UserAddress(
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      coordinates: coordinates ?? this.coordinates,
      locality: locality ?? this.locality,
      countryCode: countryCode ?? this.countryCode,
      id: id ?? this.id,
      title: title ?? this.title,
      country: country ?? this.country,
      barangay: barangay ?? this.barangay,
      region: region ?? this.region,
      state: state ?? this.state,
      street: street ?? this.street,
    );
  }

  CurrentAddress toAddress() => CurrentAddress(
        addressLine: addressLine,
        city: city,
        coordinates: coordinates,
        locality: locality,
        countryCode: countryCode,
        country: country,
        barangay: barangay,
        region: region,
        state: state,
        street: street,
      );
}
