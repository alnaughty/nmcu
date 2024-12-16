import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nomnom/app/widgets/notification_viewer.dart';
import 'package:nomnom/services/api/auth.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationHandler {
  PushNotificationHandler._pr();
  static final PushNotificationHandler _instance =
      PushNotificationHandler._pr();
  static PushNotificationHandler get instance => _instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  final AuthApi _api = AuthApi();
  final DataCacher _cacher = DataCacher.instance;
  static final LocalNotificationViewer _localNotifier =
      LocalNotificationViewer.instance;
  Future<void> initialize(ValueChanged<bool> isListenable,
      {ValueChanged<String>? onFcmTokenCreated}) async {
    // Request permissions for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    final perm = await Permission.notification.isGranted;
    if (perm) {
      // ignore: use_build_context_synchronously
      listen(fcmTokenCallback: onFcmTokenCreated);
      isListenable(true);
    } else {
      print("DENIED");
      final f = await Permission.notification.onDeniedCallback(() {
        Fluttertoast.showToast(msg: "You wont be able to receive updates");
        print("REQUEST DENIED");
      }).onGrantedCallback(() {
        listen(fcmTokenCallback: onFcmTokenCreated);
        isListenable(true);
        print("REQUEST GRANTED");
      }).request();
      // if(f == PermissionStatus.denied)
    }
  }

  Future<void> onMessageListen(context,
      {required VoidCallback onOrderReceived}) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
        if ((message.notification!.body ?? "")
                .toLowerCase()
                .contains("order") ||
            (message.notification!.title ?? "")
                .toLowerCase()
                .contains("order")) {
          onOrderReceived();
        }
        _localNotifier.showMessage(
          context,
          title: message.notification!.title ?? "Nom Nom Delivery App!",
          subtitle: message.notification!.body ?? "You have new message",
        );
      }
    });
  }

  Future<void> listen({Function(String)? fcmTokenCallback}) async {
    _firebaseMessaging.subscribeToTopic("ANNOUNCEMENT");
    print("LISTENING");
    final tok = await getToken();
    if (tok != null) {
      print("FCM TOKEN : $tok");
      final bool f = await _api.addFCMToken(tok);
      if (fcmTokenCallback != null) {
        await _cacher.saveFcmToken(tok);
        fcmTokenCallback(tok);
      }
      // await _firestore.addFcmToken(id, token)
    }
    //   if (f) {
    //     print("TOKEN SAVED");
    //   } else {
    //     print("TOKEN NOT SAVED");
    //   }
    // } else {
    //   print("TOKEN NULL");
    // }
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
