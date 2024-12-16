import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/merchant/operating_day.dart';
import 'package:nomnom/models/merchant/rating.dart';
import 'package:nomnom/models/merchant/schedule.dart';

class Merchant {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String description;
  final String municipality;
  final String barangay;
  final String address;
  final String landmark;
  final int type;
  final String? photo;
  final String? featuredPhoto;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int status;
  final String region;
  final String state;
  final String street;
  final String city;
  final GeoPoint coordinates;
  final String country;
  final int adminId;
  final dynamic services;
  final String mainRegion;
  final dynamic deletedAt;
  final double acceptanceRating;
  final int completeOrderRating;
  final int timelinessRating;
  final int feedbackRating;
  final double overallRating;
  final Rating rating;
  final CurrentSchedule currentSchedule;
  final String photoUrl;
  final String coverPhotoUrl;
  final List<OperatingDay> operatingDays;

  Merchant({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.description,
    required this.municipality,
    required this.barangay,
    required this.address,
    required this.landmark,
    required this.type,
    required this.photo,
    required this.featuredPhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.region,
    required this.state,
    required this.street,
    required this.city,
    required this.coordinates,
    required this.country,
    required this.adminId,
    this.services,
    required this.mainRegion,
    this.deletedAt,
    required this.acceptanceRating,
    required this.completeOrderRating,
    required this.timelinessRating,
    required this.feedbackRating,
    required this.overallRating,
    required this.rating,
    required this.currentSchedule,
    required this.photoUrl,
    required this.coverPhotoUrl,
    required this.operatingDays,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    final GeoPoint coordinate = json['coordinates'].toString().toGeopoint();
    final List opDays = json['operating_days'] ?? [];
    return Merchant(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phoneNumber: json['phone_number'],
        description: json['description'],
        municipality: json['municipality'],
        barangay: json['barangay'],
        address: json['address'],
        landmark: json['landmark'],
        type: json['type'],
        photo: json['photo'],
        featuredPhoto: json['featured_photo'] == null
            ? null
            : "https://back.nomnomdelivery.com${json['featured_photo']}",
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        status: json['status'],
        region: json['region'],
        state: json['state'],
        street: json['street'],
        city: json['city'],
        coordinates: coordinate,
        country: json['country'],
        adminId: json['admin_id'],
        services: json['services'],
        mainRegion: json['main_region'] ?? '',
        deletedAt: json['deleted_at'],
        acceptanceRating: json['acceptance_rating'] == null
            ? 0.0
            : double.parse(json['acceptance_rating'].toString()),
        completeOrderRating: json['complete_order_rating'] ?? 0,
        timelinessRating: json['timeliness_rating'] ?? 0,
        feedbackRating: json['feedback_rating'] ?? 0,
        overallRating: double.tryParse(json['overall_rating'].toString()) ?? 0,
        rating: json['rating'] == null
            ? Rating(averageRating: 0, count: 0, feedbacks: [])
            : Rating.fromJson(json['rating']),
        currentSchedule: CurrentSchedule.fromJson(json['current_schedule']),
        photoUrl: json['photo_url'].toString().replaceFirst("customer", 'back'),
        coverPhotoUrl: json['cover_photo_url'],
        operatingDays: opDays.map((e) => OperatingDay.fromJson(e)).toList());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'description': description,
        'municipality': municipality,
        'barangay': barangay,
        'address': address,
        'landmark': landmark,
        'type': type,
        'photo': photo,
        'featured_photo': featuredPhoto,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'status': status,
        'region': region,
        'state': state,
        'street': street,
        'city': city,
        'coordinates': coordinates,
        'country': country,
        'admin_id': adminId,
        'services': services,
        'main_region': mainRegion,
        'deleted_at': deletedAt,
        'acceptance_rating': acceptanceRating,
        'complete_order_rating': completeOrderRating,
        'timeliness_rating': timelinessRating,
        'feedback_rating': feedbackRating,
        'overall_rating': overallRating,
        'rating': rating.toJson(),
        'current_schedule': currentSchedule.toJson(),
        'photo_url': photoUrl,
        'cover_photo_url': coverPhotoUrl,
        'operating_days':
            List<dynamic>.from(operatingDays.map((x) => x.toJson())),
      };
}
