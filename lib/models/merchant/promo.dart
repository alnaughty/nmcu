import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/app/extensions/string_ext.dart';

class PromoModel {
  final int id;
  final int merchantId;
  final String title;
  final String promoCode;
  final String description;
  final int isAvailable;
  final int orderType;
  final int promoType;
  final DateTime startDate;
  final DateTime endDate;
  final String? barangay;
  final double minimumOrderAmount;
  final double price;
  final int costPoints;
  final String? photo;
  final String address;
  final String city;
  final GeoPoint? coordinates;
  final String country;
  final String endTime;
  final int indicatedCustomersCount;
  final int isAllCustomers;
  final int isAllItems;
  final int isBarangay;
  final String region;
  final String startTime;
  final String state;
  final double value;
  final int valueType;
  final String createdAt;
  final String updatedAt;
  final List<dynamic>? items;
  final List<dynamic>? locations;
  final String devices;
  final int isNews;
  final int isSpecificCustomers;
  final dynamic customers;
  final String photoUrl;
  final String startDateDisplay;
  final String endDateDisplay;
  final String periodDisplay;
  final String startTimeDisplay;
  final String endTimeDisplay;
  final String timeDisplay;

  PromoModel({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.promoCode,
    required this.description,
    required this.isAvailable,
    required this.orderType,
    required this.promoType,
    required this.startDate,
    required this.endDate,
    this.barangay,
    required this.minimumOrderAmount,
    required this.price,
    required this.costPoints,
    this.photo,
    required this.address,
    required this.city,
    required this.coordinates,
    required this.country,
    required this.endTime,
    required this.indicatedCustomersCount,
    required this.isAllCustomers,
    required this.isAllItems,
    required this.isBarangay,
    required this.region,
    required this.startTime,
    required this.state,
    required this.value,
    required this.valueType,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.locations,
    required this.devices,
    required this.isNews,
    required this.isSpecificCustomers,
    this.customers,
    required this.photoUrl,
    required this.startDateDisplay,
    required this.endDateDisplay,
    required this.periodDisplay,
    required this.startTimeDisplay,
    required this.endTimeDisplay,
    required this.timeDisplay,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    print(json['coordinates']);
    return PromoModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      title: json['title'],
      promoCode: json['promo_code'],
      description: json['description'],
      isAvailable: json['is_available'],
      orderType: json['order_type'],
      promoType: json['promo_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      barangay: json['barangay'],
      minimumOrderAmount: json['minimum_order_amount'].toDouble(),
      price: json['price'].toDouble(),
      costPoints: json['cost_points'],
      photo: json['photo'],
      address: json['address'],
      city: json['city'],
      coordinates:
          json['coordinates'] == null || json['coordinates'].toString().isEmpty
              ? null
              : json['coordinates'].toString().toGeopoint(),
      country: json['country'],
      endTime: json['end_time'],
      indicatedCustomersCount: json['indicated_customers_count'],
      isAllCustomers: json['is_all_customers'],
      isAllItems: json['is_all_items'],
      isBarangay: json['is_barangay'],
      region: json['region'],
      startTime: json['start_time'],
      state: json['state'],
      value: json['value'].toDouble(),
      valueType: json['value_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      items: json['items'],
      locations: json['locations'],
      devices: json['devices'],
      isNews: json['is_news'],
      isSpecificCustomers: json['is_specific_customers'],
      customers: json['customers'],
      photoUrl: json['photo_url'],
      startDateDisplay: json['start_date_display'],
      endDateDisplay: json['end_date_display'],
      periodDisplay: json['period_display'],
      startTimeDisplay: json['start_time_display'],
      endTimeDisplay: json['end_time_display'],
      timeDisplay: json['time_display'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'title': title,
      'promo_code': promoCode,
      'description': description,
      'is_available': isAvailable,
      'order_type': orderType,
      'promo_type': promoType,
      'start_date': startDate,
      'end_date': endDate,
      'barangay': barangay,
      'minimum_order_amount': minimumOrderAmount,
      'price': price,
      'cost_points': costPoints,
      'photo': photo,
      'address': address,
      'city': city,
      'coordinates': coordinates,
      'country': country,
      'end_time': endTime,
      'indicated_customers_count': indicatedCustomersCount,
      'is_all_customers': isAllCustomers,
      'is_all_items': isAllItems,
      'is_barangay': isBarangay,
      'region': region,
      'start_time': startTime,
      'state': state,
      'value': value,
      'value_type': valueType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items,
      'locations': locations,
      'devices': devices,
      'is_news': isNews,
      'is_specific_customers': isSpecificCustomers,
      'customers': customers,
      'photo_url': photoUrl,
      'start_date_display': startDateDisplay,
      'end_date_display': endDateDisplay,
      'period_display': periodDisplay,
      'start_time_display': startTimeDisplay,
      'end_time_display': endTimeDisplay,
      'time_display': timeDisplay,
    };
  }
}
