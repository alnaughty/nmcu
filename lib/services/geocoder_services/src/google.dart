import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/models/geocoder/coordinates.dart';
import 'package:nomnom/models/geocoder/geoaddress.dart';
import 'package:nomnom/services/env_service.dart';
import 'package:nomnom/services/geocoder_services/src/base.dart';

/// Geocoding and reverse geocoding through requests to Google APIs.
class GoogleGeocoding implements Geocoding {
  static final EnvService _env = EnvService.instance;
  static const _host = 'https://maps.google.com/maps/api/geocode/json';

  final String apiKey = _env.mapApiKey;
  final String? language;
  final Map<String, Object>? headers;
  final bool preserveHeaderCase;

  final HttpClient _httpClient;

  GoogleGeocoding({
    this.language,
    this.headers,
    this.preserveHeaderCase = false,
  }) : _httpClient = HttpClient();

  @override
  Future<List<GeoAddress>> findAddressesFromCoordinates(
      Coordinates coordinates) async {
    final url =
        '$_host?key=$apiKey${language != null ? '&language=${language!}' : ''}&latlng=${coordinates.latitude},${coordinates.longitude}';
    print(url);
    return await _send(url) ?? const <GeoAddress>[];
  }

  @override
  Future<List<GeoAddress>> findAddressesFromGeoPoint(
      GeoPoint coordinates) async {
    final url =
        '$_host?key=$apiKey${language != null ? '&language=${language!}' : ''}&latlng=${coordinates.latitude},${coordinates.longitude}';
    // return await _send(url) ?? const <GeoAddress>[];
    print(url);
    return await _send(url) ?? const <GeoAddress>[];
  }

  @override
  Future<List<GeoAddress>> findAddressesFromQuery(String address) async {
    var encoded = Uri.encodeComponent(address);
    final url = '$_host?key=$apiKey&address=$encoded';
    return await _send(url) ?? const <GeoAddress>[];
  }

  Future<List<GeoAddress>?> _send(String url) async {
    //
    final uri = Uri.parse(url);
    final request = await _httpClient.getUrl(uri);
    if (headers != null) {
      headers!.forEach((key, value) {
        request.headers.add(key, value, preserveHeaderCase: preserveHeaderCase);
      });
    }
    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    //
    var data = jsonDecode(responseBody);

    var results = data["results"];

    if (results == null) return null;

    return results
        .map(_convertAddress)
        .map<GeoAddress>((map) => GeoAddress.fromMap(map))
        .toList();
  }

  Map? _convertCoordinates(dynamic geometry) {
    if (geometry == null) return null;

    var location = geometry["location"];
    if (location == null) return null;

    return {
      "latitude": location["lat"],
      "longitude": location["lng"],
    };
  }

  Map _convertAddress(dynamic data) {
    Map result = Map();

    result["coordinates"] = _convertCoordinates(data["geometry"]);
    result["addressLine"] = data["formatted_address"];

    var addressComponents = data["address_components"];

    addressComponents.forEach((item) {
      List types = item["types"];

      if (types.contains("route")) {
        result["thoroughfare"] = item["long_name"];
      } else if (types.contains("street_number")) {
        result["subThoroughfare"] = item["long_name"];
      } else if (types.contains("country")) {
        result["countryName"] = item["long_name"];
        result["countryCode"] = item["short_name"];
      } else if (types.contains("locality")) {
        result["locality"] = item["long_name"];
      } else if (types.contains("postal_code")) {
        result["postalCode"] = item["long_name"];
      } else if (types.contains("postal_code")) {
        result["postalCode"] = item["long_name"];
      } else if (types.contains("administrative_area_level_1")) {
        result["adminArea"] = item["long_name"];
        result["adminAreaCode"] = item["short_name"];
      } else if (types.contains("administrative_area_level_2")) {
        result["subAdminArea"] = item["long_name"];
      } else if (types.contains("sublocality") ||
          types.contains("sublocality_level_1")) {
        result["subLocality"] = item["long_name"];
      } else if (types.contains("premise")) {
        result["featureName"] = item["long_name"];
      }

      result["featureName"] = result["featureName"] ?? result["addressLine"];
    });

    return result;
  }
}
