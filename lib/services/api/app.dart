import 'dart:convert';
import 'dart:io';

import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/raw_category.dart';
import 'package:nomnom/models/settings/area_settings.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/network.dart';
import 'package:http/http.dart';

class AppApi extends Network {
  static final DataCacher _cacher = DataCacher.instance;
  static String? _accessToken = _cacher.getUserToken();
  final Map<String, String> headers = {
    "Accept": "application/json",
    HttpHeaders.authorizationHeader: "Bearer $_accessToken",
  };

  Future<AreaSetting?> areaSettings({required String city}) async {
    try {
      final response = await get(
        "${endpoint}parameter/get-settings-city?city=$city".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final res = AreaSetting.fromJson(data);
        print(res);
        return res;
      }
      return null;
    } catch (e, s) {
      print("ERROR FETCHING AREA SETTINGS: $e $s");
      return null;
    }
  }

  Future<List<RawCategory>> getPredefinedCategories() async {
    try {
      final response = await get(
        "${endpoint}predefinedcategory/search".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['data'] as List;
        return result.map((e) => RawCategory.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      return [];
    }
  }
}
