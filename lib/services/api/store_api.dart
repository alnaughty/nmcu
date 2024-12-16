import 'dart:convert';
import 'dart:io';

import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/feedback/store_feedback.dart';
import 'package:nomnom/models/merchant/categorized_menu.dart';
import 'package:nomnom/models/merchant/menu_item.dart';
import 'package:nomnom/models/merchant/menu_item_details.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/merchant/promo.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/network.dart';
import 'package:http/http.dart';

class StoreApi extends Network {
  static final DataCacher _cacher = DataCacher.instance;
  static String? _accessToken = _cacher.getUserToken();
  final Map<String, String> headers = {
    "Accept": "application/json",
    HttpHeaders.authorizationHeader: "Bearer $_accessToken",
  };

  Future<List<Merchant>> search({String? keyword, String? city}) async {
    try {
      String url = "${endpoint}merchant/search?sort_by=id/desc";
      if (city != null) {
        url += "&city=$city";
      }
      if (keyword != null) {
        url += "&keyword=$keyword";
      }
      final response = await get(url.toUri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List res = data['data'] as List;
        return res.map((e) => Merchant.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      print("ERROR : $e $s");
      return [];
    }
  }

  Future<StoreFeedback> getRatingsAndFeedback(int id) async {
    try {
      return await get(
        "${endpoint}merchant/$id/rating-and-feedbacks".toUri,
        headers: headers,
      ).then((response) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final res = StoreFeedback.fromJson(data);
          print("FEEDBACK DATA : $res");
          return res;
        }
        print("asd : ${response.body}");
        return StoreFeedback(averageRating: 0, count: 0, feedbacks: []);
      });
    } catch (e, s) {
      print("ERROR STORE FEEDBACK: $e $s");
      return StoreFeedback(averageRating: 0, count: 0, feedbacks: []);
    }
  }

  Future<MenuItemDetails?> getMenuDetails(int id) async {
    try {
      final response = await get(
        "${endpoint}menuitems/$id/details".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        return MenuItemDetails.fromJson(data['result']);
      }
      return null;
    } catch (e, s) {
      print("ERROR : $e $s");
      return null;
    }
  }

  Future<List<PromoModel>> getOngoingPromo({required List<int> ids}) async {
    try {
      final response = await get(
        "${endpoint}promo/ongoing?merchant_ids=${ids.join(',')}".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List res = data['data'] as List;
        print(res);
        return res.map((e) => PromoModel.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      print("ERROR FETCHING STORE PROMO:$e $s");
      return [];
    }
  }

  Future<MenuResult> getMenu(int id) async {
    try {
      final response = await get(
        "${endpoint}menuitems/get-merchant?merchant_id=$id".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data['data']);
        return MenuResult.fromJson(data);
      }
      return MenuResult();
    } catch (e) {
      return MenuResult();
    }
  }

  Future<List<MenuItem>> searchMenu(
      {String? keyword,
      bool? isPopular,
      bool? isAvailable,
      int? merchantID}) async {
    try {
      String url =
          "${endpoint}menuitems/search?sort_by=id/desc&keyword=${keyword ?? ""}";
      if (isPopular != null) {
        url += "&is_popular=${isPopular ? 1 : 0}";
      }
      if (isAvailable != null) {
        url += "&is_available=${isAvailable ? 1 : 0}";
      }
      if (merchantID != null) {
        url += "&merchant_id=$merchantID";
      }
      // if (city != null) {
      //   url += "&city=$city";
      // }
      final response = await get(
        url.toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List d = data['data'] as List;
        return d.map((e) => MenuItem.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      print("ERROR SEARCH MENU : $e $s");
      return [];
    }
  }
}
