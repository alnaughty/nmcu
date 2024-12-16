import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/cart/cart_item.dart';
import 'package:nomnom/models/cart/cart_model.dart';
import 'package:nomnom/models/cart/order_model.dart';
import 'package:nomnom/models/cart/quotation_model.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/user/rider_firestore.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/network.dart';
import 'package:http/http.dart' as http;
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/cart_menu_listing.dart';

import '../../views/navigation_children/restaurant_page_children/options_builder.dart';

class CartApi extends Network {
  static final DataCacher _cacher = DataCacher.instance;
  static String? _accessToken = _cacher.getUserToken();
  final Map<String, String> headers = {
    "Accept": "application/json",
    HttpHeaders.authorizationHeader: "Bearer $_accessToken",
  };

  Future<List<CartModel>> get() async {
    try {
      final response = await http.get(
        "${endpoint}cart/account".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List jsonData = (data['data']);
        final groupedData = jsonData
            .fold<Map<int, List<Map<String, dynamic>>>>({}, (acc, item) {
          final merchantId = item['merchant_id'];
          acc.putIfAbsent(merchantId, () => []).add(item);
          return acc;
        });

        final res = groupedData.entries.map((entry) {
          final merchantData =
              entry.value.first; // Get representative merchant data
          final Merchant merchant = Merchant.fromJson(merchantData['merchant']);
          // final merchant = Merchant(
          //   id: merchantData['merchant_id'],
          //   name: merchantData['merchant_name'],
          // );

          final cartItems =
              entry.value.map((item) => CartItem.fromJson(item)).toList();

          return CartModel(
            merchant: merchant,
            items: cartItems,
          );
        }).toList();
        print("CART DATA: $res");
        return res;
      }
      return [];
    } catch (e, s) {
      print("ERROR : $e $s");
      return [];
    }
  }

  Future<bool> add({
    required int menuItemID,
    required int quantity,
    required double subtotal,
    required List<OptionSelection> optionSelection,
    required int orderType,
  }) async {
    try {
      final response = await http.post(
        "${endpoint}cart/save".toUri,
        body: {
          "menu_item_id": "$menuItemID",
          "quantity": "$quantity",
          "price": subtotal.toStringAsFixed(2),
          "additional_data":
              json.encode(optionSelection.map((e) => e.toJson()).toList()),
          "main_type": "$orderType",
        },
        headers: headers,
      );
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Added to cart");
      }
      return response.statusCode == 200;
    } catch (e, s) {
      print("Error : $e $s");
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      final response = await http.delete(
        "${endpoint}cart/$id/delete".toUri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Fluttertoast.showToast(msg: "Item removed from cart");
        final bool res = data['result'] == 1;
      }
      return false;
      // return response.statusCode == 200;
    } catch (e, s) {
      return false;
    }
  }

  Future<QuotationModel?> checkout({
    required int merchantId,
    required List<int> cartIds,
    required bool isPickup,
    required bool isPreorder,
    required DateTime deliveryDate,
    required TimeOfDay deliveryTime,
    required bool hasUtensils,
    required DeliveryPricing pricing,
    required double points,
    required List<RiderOpinion> riderPredictions,
    required bool isForFriend,
    required GeoPoint storeLocation,
    required GeoPoint deliveryPoint,
    required UserAddress address,
    required String landmark,
    required String note,
    required String name,
    required String lastname,
    required String middlename,
    required String mobileNumber,
    required bool isFriendPay,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "cart_ids": cartIds.join(','),
        "is_friend_pay": "${isFriendPay ? 1 : 0}",
        "is_pick_up": "${isPickup ? 1 : 0}",
        "is_preorder": "${isPreorder ? 1 : 0}",
        "preorder_delivery_date": deliveryDate.toIso8601String(),
        "preorder_delivery_time": "${deliveryTime.hour}:${deliveryTime.minute}",
        "has_utensils": "${hasUtensils ? 1 : 0}",
        "points": "$points",
        "rider_predictions":
            jsonEncode(riderPredictions.map((e) => e.toJson()).toList()),
        "delivery_details": jsonEncode([
          {
            "merchant_id": merchantId,
            "fee": pricing.deliveryFee,
          }
        ]),
        "is_for_friend": "${isForFriend ? 1 : 0}",
        "destination": "${deliveryPoint.latitude},${deliveryPoint.longitude}",
        "pickup_location":
            "${storeLocation.latitude},${storeLocation.longitude}",
        "street": address.street,
        "barangay": address.barangay,
        "city": address.city,
        "state": address.state,
        "country": address.country,
        "address": address.addressLine,
        "landmark": landmark,
        "note": note,
        "recipient_firstname": name,
        "recipient_middlename": middlename,
        "recipient_lastname": lastname,
        "mobile_number": mobileNumber,
      };
      if (pricing.promoCode.isNotEmpty) {
        body.addAll({"promo_code": pricing.promoCode});
      }
      print("CART BODY : $body");
      final response = await http.post(
          "${endpoint}quotation/food-delivery/new".toUri,
          headers: headers,
          body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QuotationModel.fromJson(data['quotation']);
      }
      return null;
    } catch (e, s) {
      print("ERROR CHECKOUT ORDER : $e $s");
      return null;
    }
  }
}
