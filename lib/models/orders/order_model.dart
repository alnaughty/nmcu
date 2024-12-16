import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nomnom/models/merchant/merchant.dart';

class OrderState {
  final int id;
  final String menuItemNames;
  final int quotationId;
  final int? riderId;
  final int customerId;
  final int merchantId;
  final int type;
  final int status;
  final String pickupLocation;
  final String destination;
  final String? title;
  final String? description;
  final String? note;
  final String address;
  final String? street;
  final String barangay;
  final String city;
  final String state;
  final String country;
  final String recipientFirstname;
  final String? recipientMiddlename;
  final String recipientLastname;
  final String? landmark;
  final String mobileNumber;
  final int points;
  final bool isForFriend;
  final double price;
  final double subtotal;
  final double vat;
  final double vatRate;
  final double discount;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double deliveryFee;
  final String reference;
  final int number;
  final String? promoCode;
  final String? paymentReference;
  final String? transactionId;
  final int reasonCode;
  final String? reason;
  final bool isPickUp;
  final double penaltiesAmount;
  final int candidateId;
  final DateTime? assignmentDatetime;
  final String? transfers;
  final bool hasUtensils;
  final bool isPreorder;
  final bool isVoucher;
  final int promoType;
  final int areaId;
  final DateTime deliveryDate;
  final bool isFriendPay;
  final String? paymentMethod;
  final bool isPaid;
  final Merchant merchant;

  OrderState(
      {required this.id,
      required this.quotationId,
      required this.menuItemNames,
      this.riderId,
      required this.customerId,
      required this.merchantId,
      required this.type,
      required this.status,
      required this.pickupLocation,
      required this.destination,
      this.title,
      this.description,
      this.note,
      required this.address,
      this.street,
      required this.barangay,
      required this.city,
      required this.state,
      required this.country,
      required this.recipientFirstname,
      this.recipientMiddlename,
      required this.recipientLastname,
      this.landmark,
      required this.mobileNumber,
      required this.points,
      required this.isForFriend,
      required this.price,
      required this.subtotal,
      required this.vat,
      required this.vatRate,
      required this.discount,
      required this.total,
      required this.createdAt,
      required this.updatedAt,
      required this.deliveryFee,
      required this.reference,
      required this.number,
      this.promoCode,
      this.paymentReference,
      this.transactionId,
      required this.reasonCode,
      this.reason,
      required this.isPickUp,
      required this.penaltiesAmount,
      required this.candidateId,
      this.assignmentDatetime,
      this.transfers,
      required this.hasUtensils,
      required this.isPreorder,
      required this.isVoucher,
      required this.promoType,
      required this.areaId,
      required this.deliveryDate,
      required this.isFriendPay,
      this.paymentMethod,
      required this.isPaid,
      required this.merchant});

  // Factory method to create an instance from JSON
  factory OrderState.fromJson(Map<String, dynamic> json) {
    final List decoded =
        json['order_items'] == null || json['order_items'].toString().isEmpty
            ? []
            : jsonDecode(json['order_items']);
    return OrderState(
      menuItemNames: decoded.map((e) => e['name']).toList().join(','),
      id: json['id'],
      quotationId: json['quotation_id'],
      riderId: json['rider_id'],
      customerId: json['customer_id'],
      merchantId: json['merchant_id'],
      type: json['type'],
      status: json['status'],
      pickupLocation: json['pickup_location'],
      destination: json['destination'],
      title: json['title'],
      description: json['description'],
      note: json['note'],
      address: json['address'],
      street: json['street'],
      barangay: json['barangay'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      recipientFirstname: json['recipient_firstname'],
      recipientMiddlename: json['recipient_middlename'],
      recipientLastname: json['recipient_lastname'],
      landmark: json['landmark'],
      mobileNumber: json['mobile_number'],
      points: json['points'],
      isForFriend: json['is_for_friend'] == 1,
      price: json['price'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      vat: json['vat'].toDouble(),
      vatRate: json['vat_rate'].toDouble(),
      discount: json['discount'].toDouble(),
      total: json['total'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deliveryFee: json['delivery_fee'].toDouble(),
      reference: json['reference'],
      number: json['number'],
      promoCode: json['promo_code'],
      paymentReference: json['payment_reference'],
      transactionId: json['tnxid'],
      reasonCode: json['reason_code'],
      reason: json['reason'],
      isPickUp: json['is_pick_up'] == 1,
      penaltiesAmount: json['penalties_amount'].toDouble(),
      candidateId: json['candidate_id'],
      assignmentDatetime: json['assignment_datetime'] != null
          ? DateTime.parse(json['assignment_datetime'])
          : null,
      transfers: json['transfers'],
      hasUtensils: json['has_utensils'] == 1,
      isPreorder: json['is_preorder'] == 1,
      isVoucher: json['is_voucher'] == 1,
      promoType: json['promo_type'],
      areaId: json['area_id'],
      deliveryDate: DateTime.parse(json['delivery_date']),
      isFriendPay: json['is_friend_pay'] == 1,
      paymentMethod: json['payment_method'],
      isPaid: json['is_paid'],
      merchant: Merchant.fromJson(json['merchant']),
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'rider_id': riderId,
      'customer_id': customerId,
      'merchant_id': merchantId,
      'type': type,
      'status': status,
      'pickup_location': pickupLocation,
      'destination': destination,
      'title': title,
      'description': description,
      'note': note,
      'address': address,
      'street': street,
      'barangay': barangay,
      'city': city,
      'state': state,
      'country': country,
      'recipient_firstname': recipientFirstname,
      'recipient_middlename': recipientMiddlename,
      'recipient_lastname': recipientLastname,
      'landmark': landmark,
      'mobile_number': mobileNumber,
      'points': points,
      'is_for_friend': isForFriend ? 1 : 0,
      'price': price,
      'subtotal': subtotal,
      'vat': vat,
      'vat_rate': vatRate,
      'discount': discount,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_fee': deliveryFee,
      'reference': reference,
      'number': number,
      'promo_code': promoCode,
      'payment_reference': paymentReference,
      'tnxid': transactionId,
      'reason_code': reasonCode,
      'reason': reason,
      'is_pick_up': isPickUp ? 1 : 0,
      'penalties_amount': penaltiesAmount,
      'candidate_id': candidateId,
      'assignment_datetime': assignmentDatetime?.toIso8601String(),
      'transfers': transfers,
      'has_utensils': hasUtensils ? 1 : 0,
      'is_preorder': isPreorder ? 1 : 0,
      'is_voucher': isVoucher ? 1 : 0,
      'promo_type': promoType,
      'area_id': areaId,
      'delivery_date': deliveryDate.toIso8601String(),
      'is_friend_pay': isFriendPay ? 1 : 0,
      'payment_method': paymentMethod,
      'is_paid': isPaid,
      'merchant': merchant.toJson(),
    };
  }

  String statusString() {
    const Map<int, String> statusMap = {
      0: 'Waiting for Store',
      1: 'Ordered',
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
