import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  EnvService._pr();
  static final EnvService _instance = EnvService._pr();
  static EnvService get instance => _instance;
  String get prod => dotenv.get("PRODUCTION_URL");
  String get dev => dotenv.get("DEVELOPMENT_URL");
  String get domain => dotenv.get("DOMAIN");
  String get mapApiKey => dotenv.get("MAP_API_KEY");
  String get senderID => dotenv.get("SENDER_ID");
}
