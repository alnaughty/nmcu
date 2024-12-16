import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/app/extensions/string_ext.dart';

class RiderFirestore {
  final int riderId;
  final GeoPoint coordinates;
  final double speed, heading;
  const RiderFirestore(
      {required this.coordinates,
      required this.heading,
      required this.riderId,
      required this.speed});

  factory RiderFirestore.fromJson(Map<String, dynamic> json) => RiderFirestore(
        coordinates:
            "${double.parse(json['latitude'].toString())},${double.parse(json['longitude'].toString())}"
                .toGeopoint(),
        heading: double.parse(json['heading'].toString()),
        riderId: json['rider_id'],
        speed: double.parse(json['speed'].toString()),
      );
}

class RiderOpinion {
  final int riderId;
  final double distance;
  const RiderOpinion({required this.distance, required this.riderId});

  factory RiderOpinion.fromJson(Map<String, dynamic> json) =>
      RiderOpinion(distance: json['distance'], riderId: json['rider_id']);

  Map<String, dynamic> toJson() => {"rider_id": riderId, "distance": distance};
}
