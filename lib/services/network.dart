import 'package:nomnom/services/env_service.dart';

mixin class Network {
  static final EnvService _env = EnvService.instance;
  static final String _endpoint = _env.prod;
  static final String domain = _env.domain;
  final String endpoint = "$_endpoint/";
}
