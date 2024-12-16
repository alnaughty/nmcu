import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhoneAuthService {
  PhoneAuthService._pr();
  static final PhoneAuthService _instance = PhoneAuthService._pr();
  static PhoneAuthService get instance => _instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> verifyPhone(
      String phone, ValueChanged<String> onIDCreated) async {
    try {
      if (phone[0] == "0") {
        phone.replaceFirst("0", "");
      }
      await _auth.verifyPhoneNumber(
        phoneNumber: "+63$phone",
        verificationCompleted: (credential) async {
          // print(credential.smsCode);
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (err) {
          Fluttertoast.showToast(msg: err.message!);
          throw Exception(err.message);
        },
        codeSent: (String verificationId, forceResendingToken) {
          onIDCreated(verificationId);
        },
        codeAutoRetrievalTimeout: (String verfiicationId) {
          onIDCreated(verfiicationId);
        },
      );
    } catch (e) {
      print("ERROR SENDING CODE : $e");
      return;
    }
  }

  Future<User?> verifyOTP({
    required String verificationID,
    required String otp,
  }) async {
    try {
      final PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationID, smsCode: otp);
      final authResult = await _auth.signInWithCredential(creds);
      return authResult.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect password");
      } else if (e.code == "") {}

      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "No internet connection");
      return null;
    } on HttpException {
      Fluttertoast.showToast(
          msg: "An error occured while processing your request");
      return null;
    } on FormatException catch (e) {
      Fluttertoast.showToast(msg: "Format error : $e");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "Connection timeout");
      return null;
    } catch (e) {
      print("PLATFORM ERROR : $e");
      return null;
    }
  }
}
