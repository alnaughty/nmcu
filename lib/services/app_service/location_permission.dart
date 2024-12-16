import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nomnom/app/extensions/geo_point_ext.dart';
import 'package:nomnom/app/mixins/geolocation_service.dart';
import 'package:nomnom/models/geocoder/geoaddress.dart';
import 'package:nomnom/models/user/current_address.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/app.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/geocoder_services/geocoder.dart';
import 'package:permission_handler/permission_handler.dart';

class NomnomLocationPermission with GeoLocationService {
  // static final UserLocationFirebaseService _locationFirebaseService =
  //     UserLocationFirebaseService();
  NomnomLocationPermission._pr();
  // final UserDataApi _api = UserDataApi();
  static final DataCacher _cacher = DataCacher.instance;
  static WidgetRef? ref;
  static final NomnomLocationPermission _instance =
      NomnomLocationPermission._pr();
  static final AppApi _appApi = AppApi();
  static NomnomLocationPermission instance(WidgetRef r) {
    ref = r;
    return _instance;
  }

  Future<void> onDeniedCallback() async {
    await Fluttertoast.showToast(
      msg: "Please enable location permission to use the app",
    );
    await Permission.location.request();
  }

  Future<void> onGrantedCallback() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await Geolocator.getCurrentPosition().then(
        (v) async {
          final List<GeoAddress> address =
              await Geocoder.google().findAddressesFromGeoPoint(v.toGeoPoint());
          if (address.isNotEmpty) {
            // _address.text = first.addressLine ?? "";
            // _brgy.text = first.subLocality ?? "";
            // _city.text = first.locality ?? "";
            // _country.text = first.countryName ?? "";
            // _state.text = first.subAdminArea ?? "";
            // _region.text = first.adminArea ?? '';
            // _street.text = first.thoroughfare ?? "";
            if (ref != null) {
              final myadd = CurrentAddress(
                addressLine: address.first.addressLine ?? "",
                city: address.first.locality ?? "",
                coordinates: v.toGeoPoint(),
                locality: address.first.subLocality ?? "",
                countryCode: address.first.countryCode ?? "",
                country: address.first.countryName ?? "",
                barangay: address.first.subLocality ?? "",
                region: address.first.adminArea ?? "",
                state: address.first.subAdminArea ?? "",
                street: address.first.thoroughfare ?? "",
              ).toUserAddress();
              print(address.first.locality);
              ref!.read(currentLocationProvider.notifier).update(
                    (state) => myadd,
                  );
              ref!.read(selectedLocationProvider.notifier).update(
                    (state) => myadd,
                  );
              await _appApi
                  .areaSettings(city: address.first.locality ?? "")
                  .then((v) {
                ref!.read(areaSettingsProvider.notifier).update((r) => v);
              });
            }
          }
        },
      );
    } else {
      final perm2 = await Geolocator.requestPermission();
      if (perm2 == LocationPermission.always ||
          perm2 == LocationPermission.whileInUse) {
        await onGrantedCallback();
      } else {
        openAppSettings();
      }
    }
  }

  onPermanentlyDeniedCallback() async {
    final bool isGranted = await openAppSettings();
    if (isGranted) {
      await onGrantedCallback();
    } else {
      await onDeniedCallback();
    }
  }

  // onProvisionalCallback() {}

  // Future<void> receivedValue(Position p) async {
  //   if (ref == null) return;
  //   Position? pos = ref!.read(coordinateProvider);
  //   final bool isNew = pos == null;

  //   pos ??= p;
  //   final double dist =
  //       distance(pos.latitude, pos.longitude, p.latitude, p.longitude);
  //   ref!.read(coordinateProvider.notifier).update((state) => p);

  //   if ((dist * 1000) < (Platform.isAndroid ? 2 : 1) && !isNew) return;

  //   final User? user = FirebaseAuth.instance.currentUser;
  //   final UserModel? _currentUser = ref!.watch(currentUser);

  //   if (user == null || _currentUser == null) return;
  //   _locationFirebaseService.updateOrCreateUserLocation(
  //     user,
  //     Coordinates(
  //       pos.latitude,
  //       pos.longitude,
  //     ),
  //     _currentUser,
  //   );
  // }
}

// void printWrapped(String text) {
//   final pattern = RegExp('.{1,900}'); // Adjust the length as needed
//   pattern.allMatches(text).forEach((match) {
//     print(match.group(0));
//   });
// }
