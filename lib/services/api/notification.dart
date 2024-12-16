import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/env_service.dart';
import 'package:nomnom/services/network.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationConfig with Network {
  static final DataCacher _cacher = DataCacher.instance;
  static String? accessToken = _cacher.getUserToken();
  static final EnvService _env = EnvService.instance;
  final Map<String, String> headers = {
    "Accept": "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
  Future<void> sendPushMessage({
    required List<String> registrationTokens,
    required String title,
    required String body,
  }) async {
    final jsonCredentials =
        await rootBundle.loadString('send-message-prereq.json');
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    for (String token in registrationTokens) {
      final notificationData = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body}
        },
      };
      final client = await auth.clientViaServiceAccount(
        creds,
        ['https://www.googleapis.com/auth/cloud-platform'],
      );

      final String senderId = _env.senderID;
      final response = await client.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode(notificationData),
      );
      client.close();
      if (response.statusCode == 200) {
        print(response.body);
        // Fluttertoast.showToast(msg: "Message sent!");
        print("SUCCESS");
        // return true; // Success!
      }
    }
  }
}
