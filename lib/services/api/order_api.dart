import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/cart/order_model.dart';
import 'package:nomnom/models/orders/order_model.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/network.dart';

class OrderApi extends Network {
  static final DataCacher _cacher = DataCacher.instance;
  static final String? _accessToken = _cacher.getUserToken();
  final Map<String, String> headers = {
    "Accept": "application/json",
    HttpHeaders.authorizationHeader: "Bearer $_accessToken",
  };

  Future<List<OrderState>> activeOrders() async {
    try {
      final response = await http.get(
        "${endpoint}order/active?sort_by=id/desc".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<OrderState> result =
            (data as List).map((e) => OrderState.fromJson(e)).toList();
        print("ACTIVE ORDERS : $result");
        return result;
      }
      return [];
    } catch (e, s) {
      print("ERROR ACTIVE ORDERS : $e $s");
      return [];
    }
  }

  Future<List<OrderState>> history() async {
    try {
      final response = await http.get(
        "${endpoint}order/history?sort_by=id/desc".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<OrderState> result =
            (data as List).map((e) => OrderState.fromJson(e)).toList();
        print("HISTORY ORDERS : $result");
        return result;
      }
      return [];
    } catch (e, s) {
      print("ERROR HISTORY ORDERS : $e $s");
      return [];
    }
  }

  Future<OrderModel?> getDetails(int id) async {
    try {
      final response = await http.get(
        "${endpoint}order/$id/details".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderModel.fromJson(data['order']);
      }
      return null;
    } catch (e, s) {
      print("ERROR: $e $s");
      return null;
    }
  }

  Future<bool> reviewStore(
      {required int orderID,
      required int rate,
      required String feedback}) async {
    try {
      final response = await http
          .post("${endpoint}feedback/store/add".toUri, headers: headers, body: {
        "order_id": "$orderID",
        "rate": "$rate",
        "feedback": feedback,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reviewRider(
      {required int orderID,
      required int rate,
      required int riderID,
      required String feedback}) async {
    try {
      final response = await http
          .post("${endpoint}feedback/rider/add".toUri, headers: headers, body: {
        "order_id": "$orderID",
        "rate": "$rate",
        "feedback": feedback,
        "rider_id": "$riderID"
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
