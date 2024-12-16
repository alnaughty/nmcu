import 'dart:convert';

import 'package:nomnom/models/geocoder/autocomplete_prediction.dart';

class PlaceAutocompleteResponse {
  final String? status;
  final List<AutocompletePrediction> predictions;
  const PlaceAutocompleteResponse({this.status, required this.predictions});

  factory PlaceAutocompleteResponse.fromJson(Map<String, dynamic> json) =>
      PlaceAutocompleteResponse(
          status: json['status'] as String?,
          predictions: json['predictions'] != null
              ? json['predictions']
                  .map<AutocompletePrediction>(
                      (e) => AutocompletePrediction.fromJson(e))
                  .toList()
              : []);

  static PlaceAutocompleteResponse parseAutocompleteResult(
      String responseBody) {
    final parse = json.decode(responseBody).cast<String, dynamic>();
    return PlaceAutocompleteResponse.fromJson(parse);
  }
}
