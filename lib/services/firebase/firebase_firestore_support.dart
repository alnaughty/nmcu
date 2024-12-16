import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nomnom/app/extensions/date_ext.dart';
import 'package:nomnom/app/extensions/time_ext.dart';
import 'package:nomnom/models/cart/order_model.dart';
import 'package:nomnom/models/chatroom.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/user/rider_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;

class FirebaseFirestoreSupport {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final riderCollection =
      FirebaseFirestore.instance.collection('rider-location');
  final orderCollection = FirebaseFirestore.instance.collection('order-data');
  final fcmTokenCollection =
      FirebaseFirestore.instance.collection('fcm-tokens');
  final chatroomCollection =
      FirebaseFirestore.instance.collection('order-chatroom');
  Future<void> updateETA(String refcode, double eta) async {
    await orderCollection
        .doc(refcode)
        .set({"eta": eta}, SetOptions(merge: true));
  }

  Future<DeliveryModel?> getRealtimeData(
      {required String referenceCode}) async {
    DocumentSnapshot doc = await orderCollection.doc(referenceCode).get();
    DeliveryModel? delivery =
        DeliveryModel.fromFirestore(doc.data() as Map<String, dynamic>);
    return delivery;
  }

  Stream<DeliveryModel?> listenToSpecificItem({required String referenceCode}) {
    return orderCollection.doc(referenceCode).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return DeliveryModel.fromFirestore(snapshot.data()!);
      } else {
        return null;
      }
    });
  }

  Future<void> review(
      {required String refcode,
      required String key,
      required FireRating rate}) async {
    await orderCollection.doc(refcode).update({
      "$key.rate": rate.toJson(),
    });
  }

  Stream<List<DeliveryModel>> listenToDeliveries(
      {required int value, required String key}) {
    final collection = FirebaseFirestore.instance.collection('order-data');

    // Listen to Firestore and map the QuerySnapshot to List<DeliveryModel>
    return collection
        .where(key, isEqualTo: value)
        .snapshots()
        .map((snapshot) => convertQuerySnapshotToList(snapshot));
  }

  Stream<RiderFirestore?> listenSpecificRider(int riderId) {
    return riderCollection.doc("$riderId").snapshots().map((e) {
      if (e.exists) {
        return RiderFirestore.fromJson(e.data()!);
      } else {
        return null;
      }
    });
  }

  Stream<List<DeliveryModel>> listenRider(
      {required int value, required String key}) {
    final collection = FirebaseFirestore.instance.collection('order-data');

    // Listen to Firestore and map the QuerySnapshot to List<DeliveryModel>
    // StreamGroup.merge(streams)
    return collection
        .where(key, isEqualTo: value, arrayContains: value)
        .snapshots()
        .map((snapshot) => convertQuerySnapshotToList(snapshot));
  }

  List<DeliveryModel> convertQuerySnapshotToList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return DeliveryModel.fromFirestore(data);
    }).toList();
  }

  Future<List<RiderFirestore>> getRidersFromFirestore() async {
    final riderSnapshot = await riderCollection.get();
    List<RiderFirestore> riders = riderSnapshot.docs.map((doc) {
      return RiderFirestore(
        coordinates: GeoPoint(
          doc['latitude'],
          doc['longitude'],
        ),
        riderId: doc['rider_id'],
        speed: doc['speed'], heading: doc['heading'],

        // id: doc.id,
        // latitude: doc['latitude'],
        // longitude: doc['longitude'],
      );
    }).toList();
    return riders;
  }

  Stream<List<Chat>> fetchMessages({required String refcode}) {
    final query =
        chatroomCollection.where("id", isEqualTo: refcode).snapshots();
    return query.map((e) {
      return e.docs.map((x) => Chat.fromFirestore(x.data(), x.id)).toList();
    });
  }

  Stream<ChatroomModel> listenToChatroom({required String refcode}) {
    return chatroomCollection.doc(refcode).snapshots().map((doc) {
      if (doc.exists) {
        return ChatroomModel.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception("Chatroom not found");
      }
    });
  }

  Future<void> updateStatus(
      {required String refcode, required int status}) async {
    await orderCollection
        .doc(refcode)
        .set({"status": status}, SetOptions(merge: true));
  }

  // Future<void> createChatroom({required String refcode}) async {
  //   final chatroomDoc = await FirebaseFirestore.instance
  //       .collection('order-chatroom')
  //       .doc(refcode)
  //       .get();
  //   if (!chatroomDoc.exists) {
  //     final Map<String, dynamic> data = {
  //       "chats": [],
  //       "updated_at": FieldValue.serverTimestamp(),
  //     };
  //     await FirebaseFirestore.instance
  //         .collection('order-chatroom')
  //         .doc(refcode)
  //         .set(data);
  //   }
  // }

  Future<String> uploadPhoto(File file, String fileName, String refCode) async {
    // Reference to Firebase Storage
    final storageRef = fs.FirebaseStorage.instance
        .ref()
        .child('messages_photos/$refCode/$fileName');

    // Upload the file
    await storageRef.putFile(file);

    // Get the file URL
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  Future<void> addNewMessage(
      {required String message,
      required String refcode,
      required int senderID,
      required String senderAvatar,
      required String senderName,
      File? photo}) async {
    try {
      final Map<String, dynamic> data = {
        "sender_id": senderID,
        "message": message,
        "sender_name": senderName,
        "id": refcode,
        "sender_avatar": senderAvatar,
        "timestamp": FieldValue.serverTimestamp(),
      };
      if (photo != null) {
        final filename = "$refcode-${DateTime.now().millisecondsSinceEpoch}";
        final photoUrl = await uploadPhoto(photo, filename, refcode);
        data.addAll({"photo_url": photoUrl});
      }

      await chatroomCollection.add(data);
      await orderCollection.doc(refcode).update({
        "message_count": FieldValue.increment(1),
      });

      // return await FirebaseFirestore.instance
      //     .collection('order-chatroom')
      //     .doc(refcode)
      //     .update({
      //   "chats": FieldValue.arrayUnion([data]),
      //   "updated_at": FieldValue.serverTimestamp(),
      // }).catchError((e, s) {
      //   print("ERROR CAUGHT : $e $s");
      // });
    } catch (e, s) {
      print("ERROR ADDING NEW MESSAGE : $e $s");
      return;
    }
  }

  Future<void> addNewOrder(OrderModel order, int eta, bool isFriendPay, int uid,
      {required Merchant merchant,
      required String items,
      required List<int> riderIds}) async {
    final TimeOfDay delTime =
        order.deliveryDate.toTimeOfDay().addMinutes(eta + 10);

    final Map<String, dynamic> data = {
      "merchant": {
        "name": merchant.name,
        "photo": merchant.photoUrl,
        "coordinates":
            "${merchant.coordinates.latitude},${merchant.coordinates.longitude}",
      },
      "rider_candidates": riderIds,
      "items_string": items,
      "user_id": uid,
      "prep_time": null,
      'is_pre_order': order.isPreorder,
      "is_pick_up": order.isPickUp,
      "id": order.id,
      'reference': order.reference,
      "status": order.status,
      'is_pay_friend': isFriendPay,
      "eta": eta,
      'timestamp': DateTime.now().toIso8601String(),
      'recipient': {
        "name": "${order.recipientFirstname} ${order.recipientLastname}",
        "contact_number": order.mobileNumber,
      },
      "message_count": 0,
      "is_for_friend": order.isForFriend,
      "delivery_time": "${delTime.hour}:${delTime.minute}",
      "delivery_date": order.deliveryDate.toIso8601String(),
      "total": order.total,
      "delivery_fee": order.deliveryFee,
      "merchant_id": order.merchantId,
      "rider_coordinates": null,
      "rider": null,
      "destination": {
        "coordinates":
            "${order.destination.latitude},${order.destination.longitude}",
        "address": order.address,
        "city": order.city,
      }
    };
    await orderCollection
        .doc(order.reference)
        .set(data, SetOptions(merge: true))
        .onError((error, s) {
      print("ERROR ADDING TO FIREBASE $error $s");
    });
  }

  Future<void> addFcmToken(int id, String token) async {
    await fcmTokenCollection.doc("$id").set({
      "tokens": FieldValue.arrayUnion([token])
    });
  }

  Future<List<String>> getTokens(int id) async {
    DocumentSnapshot doc = await fcmTokenCollection.doc("$id").get();
    final List results = doc.get("tokens") ?? [];
    // DeliveryModel.fromFirestore(doc.data() as Map<String, dynamic>);
    return results.map((e) => e.toString()).toList();
  }

  Future<void> removeToken(int id, String token) async {
    await fcmTokenCollection.doc("$id").set({
      "tokens": FieldValue.arrayRemove([token])
    });
  }
}
