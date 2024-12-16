import 'package:shared_preferences/shared_preferences.dart';

class DataCacher {
  DataCacher._pr();
  static final DataCacher _instance = DataCacher._pr();
  static DataCacher get instance => _instance;
  late final SharedPreferences _prefs;

  Future<void> logout() async {
    await removeFcmToken();
    await removeToken();
    await removeLoginValue();
    await removeSignInMethod();
    await removeUID();
    await removeFirebaseToken();
    return;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUID(String uid) async {
    await _prefs.setString("uid", uid);
  }

  Future<void> removeUID() async => await _prefs.remove("uid");
  String? getUID() => _prefs.getString("uid");

  Future<void> saveSignedEmail(String email) async =>
      await _prefs.setString('saved-email', email);
  String? signedEmail() => _prefs.getString('saved-email');
  Future<void> removeEmail() async => _prefs.remove('saved-email');

  //*
  //0 = phone
  //1 = google
  //2 = apple
  //3 = facebook
  //*/
  Future<void> signInMethod(int i) async {
    await _prefs.setInt("sign-in-method", i);
  }

  int getSignInMethod() => _prefs.getInt("sign-in-method") ?? 0;
  Future<void> removeSignInMethod() async =>
      await _prefs.remove('sign-in-method');
  /*
  Firebase Token preparation to revoke from backend
   */
  Future<void> saveFcmToken(String tok) async {
    await _prefs.setString("fcm-token", tok);
  }

  Future<void> removeFcmToken() async => await _prefs.remove('fcm-token');
  String? getFcmToken() => _prefs.getString('fcm-token');

  /*
  User Access Token handler for easy login
   */
  String? getUserToken() => _prefs.getString("access-token");
  Future<void> setUserToken(String token) async {
    await _prefs.setString("access-token", token);
  }

  Future<void> removeToken() async => await _prefs.remove("access-token");
  /*
  FIREBASE ACCESSTOKEN FOR VALIDATION
   */
  Future<void> setFirebaseToken(String t) async =>
      await _prefs.setString('firebase_token', t);

  Future<void> removeFirebaseToken() async =>
      await _prefs.remove('firebase_token');
  String? firebaseToken() => _prefs.getString('firebase_token');
  Future<void> setLoginTypeValue(String value) async {
    await _prefs.setString("login-value", value);
  }

  String? loginValue() => _prefs.getString("login-value");
  Future<void> removeLoginValue() async => await _prefs.remove("login-value");
  Future<void> setUserID(int id) async => await _prefs.setInt('user-id', id);
  int? getUserID() => _prefs.getInt('user-id');
  Future<void> removeUserID() async => await _prefs.remove("user-id");

  // remove user token
}
