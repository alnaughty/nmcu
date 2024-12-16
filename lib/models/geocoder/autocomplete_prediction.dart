class AutocompletePrediction {
  final String? description;
  // final StructuredFormatting? structuredFormatting;
  final String? placeID, reference;
  final StructuredFormatting? formatting;
  const AutocompletePrediction(
      {this.description, this.placeID, this.reference, this.formatting});

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) =>
      AutocompletePrediction(
          description: json['description'] as String?,
          placeID: json['place_id'] as String?,
          reference: json['reference'] as String?,
          formatting: json['structured_formatting'] != null
              ? StructuredFormatting.fromJson(json['structured_formatting'])
              : null);
}

class StructuredFormatting {
  final String? mainText, secondaryText;
  const StructuredFormatting({this.mainText, this.secondaryText});
  factory StructuredFormatting.fromJson(Map<String, dynamic> json) =>
      StructuredFormatting(
        mainText: json['main_text'] as String?,
        secondaryText: json['secondary_text'] as String?,
      );
}
