import 'package:nomnom/services/geocoder_services/src/base.dart';
import 'package:nomnom/services/geocoder_services/src/google.dart';

class Geocoder {
  // static final Geocoding local = LocalGeocoding();
  static Geocoding google({
    String? language,
    Map<String, Object>? headers,
    bool preserveHeaderCase = false,
  }) =>
      GoogleGeocoding(
          language: language,
          headers: headers,
          preserveHeaderCase: preserveHeaderCase);
}
