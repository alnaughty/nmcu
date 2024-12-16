import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/app/extensions/string_ext.dart';

class FireDestination {
  final String address;
  final String city;
  final GeoPoint coordinates;

  FireDestination({
    required this.address,
    required this.city,
    required this.coordinates,
  });

  // Factory method to create an instance from Firestore document data
  factory FireDestination.fromFirestore(Map<String, dynamic> data) {
    return FireDestination(
      address: data['address'] as String,
      city: data['city'] as String,
      coordinates: data['coordinates'].toString().toGeopoint(),
    );
  }

  // Method to convert the instance to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'address': address,
      'city': city,
      'coordinates': coordinates,
    };
  }
}
