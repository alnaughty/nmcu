class Coordinates {
  /// The geographic coordinate that specifies the north–south position of a point on the Earth's surface.
  final double latitude;

  /// The geographic coordinate that specifies the east-west position of a point on the Earth's surface.
  final double longitude;

  Coordinates(this.latitude, this.longitude);

  /// Creates coordinates from a map containing its properties.
  Coordinates.fromMap(Map map)
      : latitude = map["latitude"],
        longitude = map["longitude"];
  factory Coordinates.fromJsonFirebase(Map<String, dynamic> json) {
    return Coordinates(json['lat'], json['lng']);
  }
  // Coordinates.fromJsonFirebase(Map<String, dynamic> json)
  // : latitude = 12.323525,
  //   longitude = 24.12315;

  /// Creates a map from the coordinates properties.
  Map toMap() => {
        "latitude": latitude,
        "longitude": longitude,
      };
  @override
  String toString() => "$latitude,$longitude";
}
