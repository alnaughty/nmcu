import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/extensions/time_ext.dart';
import 'package:nomnom/models/orders/firebase_destination.dart';
import 'package:nomnom/models/orders/firebase_recipient.dart';

class FireRating {
  final int rate;
  final String feedback;
  const FireRating({required this.feedback, required this.rate});
  factory FireRating.fromJson(Map<String, dynamic> json) => FireRating(
        feedback: json['feedback'] as String,
        rate: json['rate'] as int,
      );

  Map<String, dynamic> toJson() => {
        "feedback": feedback,
        "rate": rate,
      };

  @override
  String toString() => "${toJson()}";
}

class FireRider {
  final String fullname, photoUrl;
  final int id;
  final FireRating? rate;
  const FireRider(
      {required this.fullname,
      required this.id,
      required this.photoUrl,
      required this.rate});

  factory FireRider.fromJson(Map<String, dynamic> json) => FireRider(
        rate: json['rate'] == null ? null : FireRating.fromJson(json['rate']),
        fullname: json['fullname'],
        id: json['id'],
        photoUrl: json['photo_url'],
      );

  Map<String, dynamic> toJson() => {
        "rate": rate?.toJson(),
        "id": id,
        "photo_url": photoUrl,
        "fullname": fullname,
      };
}

class FireMerchant {
  final String name, photoUrl;
  final GeoPoint coordinates;
  final FireRating? rate;
  const FireMerchant(
      {required this.name,
      required this.photoUrl,
      required this.coordinates,
      required this.rate});

  factory FireMerchant.fromJson(Map<String, dynamic> json) => FireMerchant(
        rate: json['rate'] == null ? null : FireRating.fromJson(json['rate']),
        name: json['name'],
        coordinates: json['coordinates'].toString().toGeopoint(),
        photoUrl: json['photo'],
      );

  Map<String, dynamic> toJson() => {
        "rate": rate?.toJson(),
        "name": name,
        "photo_url": photoUrl,
        "coordinates": "${coordinates.latitude},${coordinates.longitude}",
      };
}

class DeliveryModel {
  final FireMerchant merchant;
  final DateTime deliveryDate;
  final double deliveryFee;
  final TimeOfDay deliveryTime;
  final FireDestination destination;
  final double eta;
  final DateTime? prepTime;
  final int id;
  final bool isForFriend;
  final bool isPickup, isFriendPay;
  final bool isPreorder;
  final int merchantId;
  final FireRecipient recipient;
  final GeoPoint? riderCoordinates;
  final FireRider? rider;
  final int status;
  final String timestamp, reference;
  final double total;
  final String itemsString;

  DeliveryModel({
    required this.merchant,
    required this.deliveryTime,
    required this.deliveryDate,
    required this.deliveryFee,
    required this.reference,
    required this.destination,
    required this.eta,
    required this.prepTime,
    required this.isFriendPay,
    required this.id,
    required this.isForFriend,
    required this.merchantId,
    required this.recipient,
    required this.riderCoordinates,
    required this.rider,
    required this.status,
    required this.isPickup,
    required this.isPreorder,
    required this.timestamp,
    required this.total,
    required this.itemsString,
  });
// 'is_pre_order': order.isPreorder,
//       "is_pick_up": order.isPickUp,
  factory DeliveryModel.fromFirestore(Map<String, dynamic> data) {
    return DeliveryModel(
      merchant: FireMerchant.fromJson(data['merchant']),
      prepTime:
          data['prep_time'] == null ? null : DateTime.parse(data['prep_time']),
      isFriendPay:
          data['is_pay_friend'] == null ? false : data['is_pay_friend'] as bool,
      reference: data['reference'] as String,
      deliveryTime: data['delivery_time'] == null
          ? TimeOfDay.now()
          : (data['delivery_time'] as String).toTimeOfDay,
      deliveryDate: DateTime.parse(data['delivery_date']),
      deliveryFee: (data['delivery_fee'] as num).toDouble(),
      destination: FireDestination.fromFirestore(
          data['destination'] as Map<String, dynamic>),
      eta: double.parse(data['eta'].toString()),
      id: data['id'] as int,
      isPreorder: data['is_pre_order'] as bool,
      isPickup: data['is_pick_up'] as bool,
      isForFriend: data['is_for_friend'] as bool,
      merchantId: data['merchant_id'] as int,
      recipient: FireRecipient.fromFirestore(
          data['recipient'] as Map<String, dynamic>),
      riderCoordinates: data['rider_coordinates'] == null
          ? null
          : (data['rider_coordinates'] as String).toGeopoint(),
      rider: data['rider'] == null ? null : FireRider.fromJson(data['rider']),
      status: data['status'] as int,
      timestamp: data['timestamp'] as String,
      total: (data['total'] as num).toDouble(),
      itemsString: data['items_string'] as String,
    );
  }

  // Method to convert the instance to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      "merchant": merchant.toJson(),
      "prep_time": prepTime,
      "is_pay_friend": isFriendPay,
      "is_pick_up": isPickup,
      "is_preorder": isPreorder,
      "reference": reference,
      'delivery_time': deliveryTime.toStringPayload(),
      'delivery_date': deliveryDate,
      'delivery_fee': deliveryFee,
      'destination': destination.toFirestore(),
      'eta': eta,
      'id': id,
      'is_for_friend': isForFriend,
      'merchant_id': merchantId,
      'recipient': recipient.toFirestore(),
      'rider_coordinates': riderCoordinates,
      'rider': rider?.toJson(),
      'status': status,
      'timestamp': timestamp,
      'total': total,
      "items_string": itemsString
    };
  }

  String statusString() {
    const Map<int, String> statusMap = {
      0: 'Waiting for Store',
      1: 'Preparing Order',
      11: 'Assigned',
      2: 'Ready for Pickup',
      3: 'Picked Up',
      4: 'Arrived',
      5: 'Delivered',
      6: 'Not Accepted',
      7: 'Cancelled',
      8: 'System Cancelled',
      9: 'Remitted',
    };

    return statusMap[status] ?? 'Unknown Status';
  }

  Color statusColor() {
    const Map<int, Color> statusColorMap = {
      0: Colors.orange, // Waiting for Store
      1: Color(0xFF50A3FB), // Ordered
      11: Color(0xFF993CFC), // Assigned
      2: Color(0xFF26DE57), // Ready for Pickup
      3: Colors.teal, // Picked Up
      4: Color(0xFF26DE57), // Arrived
      5: Color(0xFF26DE57), // Delivered
      6: Color(0xFFFF0000), // Not Accepted
      7: Color(0xFFFF0000), // Cancelled
      8: Color(0xFFFF0000), // System Cancelled
      9: Colors.yellow, // Remitted
    };

    return statusColorMap[status] ??
        Colors.black; // Default to black for unknown statuses
  }
}
