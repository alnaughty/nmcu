import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/network.dart';

class AuthApi extends Network {
  static final DataCacher _cacher = DataCacher.instance;
  String? accessToken = _cacher.getUserToken();
  Future<bool> logout() async {
    try {
      if (accessToken == null) {
        Fluttertoast.showToast(msg: "Unrecognized login");
        return false;
      }
      return await http.get("${endpoint}auth/logout".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) {
        return response.statusCode == 200;
      });
    } catch (e) {
      print("LOGOUT ERROR : $e");
      return false;
    }
  }

  Future<String?> signIn(String firebaseToken, [String? email]) async {
    try {
      final Map<String, dynamic> body = {
        "firebase_token": firebaseToken,
      };
      if (email != null) {
        body.addAll({"email": email});
      }
      return http
          .post("${endpoint}auth/login".toUri, body: body)
          .then((response) {
        print(response.body);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print("DATA : ${data['access_token']}");
          _cacher.setUserToken(data['access_token']);
          if (email != null) {
            _cacher.setLoginTypeValue(email);
          }
          print(data);
          return data['access_token'];
        } else if (response.statusCode == 404) {
          print(response.body);
          Fluttertoast.showToast(msg: "Token expired, please relogin");
          return null;
        }
        return null;
      });
    } on FormatException {
      return null;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "An unexpected error occurred while trying to authenticate");
      return null;
    }
  }

  Future<bool> updatePicture(File file) async {
    try {
      accessToken = _cacher.getUserToken();
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);
      // Determine the MIME type based on the file extension
      String mimeType = 'image/jpeg'; // Default to JPEG
      if (file.path.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (file.path.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (file.path.endsWith('.bmp')) {
        mimeType = 'image/bmp';
      }
      final String image = 'data:$mimeType;base64,$base64String';
      return await http
          .post("${endpoint}client/profile/update-image".toUri, body: {
        "image": image,
      }, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) {
        print(response.body);
        return response.statusCode == 200;
      });
    } catch (e) {
      print("UPDATE PIC ERROR : $e");
      return false;
    }
  }

  Future<bool> updateProfile(UserModel user) async {
    try {
      accessToken = _cacher.getUserToken();
      return await http.post("${endpoint}client/profile/update".toUri,
          body: user.toJson2(),
          headers: {
            "Accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken",
          }).then((response) {
        return response.statusCode == 200;
      });
    } catch (e, s) {
      print("UPDATE ERROR : $e $s");
      return false;
    }
  }

  Future<String?> createUserProfile(UserModel user) async {
    try {
      final String? firebaseToken = _cacher.firebaseToken();
      if (firebaseToken == null) {
        Fluttertoast.showToast(msg: "No Firebase Token Found");
        return null;
      }
      accessToken ??= _cacher.getUserToken();
      return await http.post("${endpoint}client/register".toUri, body: {
        'firebase_token': firebaseToken,
        'email': user.email
      }, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) async {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await updateProfile(user);
          print(data);
          // await _cacher.setUserToken(data['access_token']);
          return data['access_token'];
        }
        print(response.body);
        return null;
      });
    } catch (e, s) {
      print("ERROR REGISTER : $e\n$s");
      return null;
    }
  }

  Future<UserModel?> getUserDetails() async {
    try {
      accessToken = _cacher.getUserToken();
      return await http.get("${endpoint}client/profile/get".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) {
        final data = json.decode(response.body);
        print("DATA USER DETAILS: $data");
        if (response.statusCode == 200) {
          print("ASD");
          final UserModel user = UserModel.fromJson(data['result']);
          _cacher.setUserID(user.id);
          return user;
        }
        return null;
      });
    } on FormatException catch (e) {
      print("FORMAT : $e");
      return null;
    } catch (e, s) {
      print("ASASD : $e $s");
      return null;
    }
  }

  Future<UserAddress?> saveNewAddress({
    required String address,
    required String brgy,
    required String state,
    required String city,
    required String country,
    required GeoPoint coordinates,
    required String title,
    required String region,
    required String street,
  }) async {
    try {
      accessToken = _cacher.getUserToken();
      final response =
          await http.post("${endpoint}client/address/add".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }, body: {
        "address": address,
        "state": state,
        "city": city,
        "country": country,
        "coordinates": "${coordinates.latitude},${coordinates.longitude}",
        "title": title,
        "barangay": brgy,
        "region": region,
        "street": street,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Fluttertoast.showToast(msg: "New address saved");
        return UserAddress.fromJson(data['result']);
      }
      return null;
    } catch (e, s) {
      print("ERROR ADDING ADDRESS : $e $s");
      return null;
    }
  }

  Future<bool> addFCMToken(String token) async {
    try {
      final response =
          await http.post("${endpoint}client/fcm/add".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }, body: {
        "token": token
      });
      return response.statusCode == 200;
    } catch (e, s) {
      print("ERROR ADDING FCM TOKEN : $e $s");
      return false;
    }
  }

  Future<double> getPoints() async {
    try {
      final response =
          await http.get("${endpoint}client/points".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return double.tryParse(data['points'].toString()) ?? 0.0;
      }
      return 0;
    } catch (e, s) {
      print("ERROR FETCHING NOMNOM POINTS : $e $s");
      return 0.0;
    }
  }
}
