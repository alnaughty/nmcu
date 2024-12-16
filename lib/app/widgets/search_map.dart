import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/models/geocoder/autocomplete_prediction.dart';
import 'package:nomnom/models/geocoder/geoaddress.dart';
import 'package:nomnom/models/geocoder/place_autocomplete_response.dart';
import 'package:nomnom/services/env_service.dart';
import 'package:nomnom/services/geocoder_services/geocoder.dart';
// import 'package:nomnom_merchant_portal/app/color_palette.dart';
// import 'package:nomnom_merchant_portal/config/color_ext.dart';
// import 'package:nomnom_merchant_portal/models/geocoder/autocomplete_prediction.dart';
// import 'package:nomnom_merchant_portal/models/geocoder/geo_point.dart';
// import 'package:nomnom_merchant_portal/models/geocoder/geoaddress.dart';
// import 'package:nomnom_merchant_portal/models/geocoder/place_autocomplete_response.dart';
// import 'package:nomnom_merchant_portal/services/env_service.dart';
// import 'package:nomnom_merchant_portal/services/geocoder_services/geocoder.dart';

class SearchMap extends ConsumerStatefulWidget {
  const SearchMap({super.key, required this.callback});
  final ValueChanged<GeoPoint> callback;
  @override
  ConsumerState<SearchMap> createState() => _SearchMapState();
}

class _SearchMapState extends ConsumerState<SearchMap> with ColorPalette {
  List<AutocompletePrediction> places = [];
  final EnvService _env = EnvService.instance;
  final TextEditingController _search = TextEditingController();
  final _debounceDuration = const Duration(milliseconds: 500);
  Timer? _debounceTimer;
  Future<void> placeAutocomplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": _env.mapApiKey,
    });
    print(uri);
    String? response = await fetch(uri);
    print("DATA : $response");
    if (response != null) {
      final PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      setState(() {
        places = result.predictions;
      });
    }
  }

  Future<String?> fetch(Uri uri) async {
    try {
      return await http.get(uri).then((response) {
        if (response.statusCode == 200) {
          return response.body;
        }
        return null;
      });
    } catch (e) {
      print("ERROR : $e");
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _debounceTimer?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      // _fetchPlacePredictions(_controller.text);
      placeAutocomplete(_search.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = scaffoldColor;
    final Color textColor = darkGrey;
    final Size size = MediaQuery.of(context).size;
    // var darkMode = ref.watch(darkModeProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          // leading: ,
          centerTitle: false,
          leading: Icon(
            CupertinoIcons.location_fill,
            size: 25,
            color: textColor,
          ),
          // leading: IconButton.filled(
          //   onPressed: null,
          //   icon:
          // ),
          actions: [
            IconButton.filled(
              onPressed: () {
                if (context.canPop()) {
                  Navigator.of(context).pop();
                }
              },
              color: bgColor,
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith((s) => bgColor.darken())),
              icon: Icon(
                Icons.close,
                color: textColor,
                size: 20,
              ),
            )
          ],
          title: const Text("Search Location"),
          titleTextStyle: TextStyle(
              color: textColor, fontSize: 20, fontWeight: FontWeight.w600),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Gap(10),
                  TextField(
                    controller: _search,
                    style: TextStyle(color: textColor),
                    cursorHeight: 20,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        filled: true,
                        fillColor: bgColor.darken(),
                        prefixIcon: Icon(
                          CupertinoIcons.location_circle,
                          color: textColor.withOpacity(.5),
                          size: 25,
                        ),
                        hintText: "Search",
                        hintStyle: TextStyle(color: textColor.withOpacity(.5)),
                        prefixIconConstraints: const BoxConstraints(
                            maxHeight: 55,
                            maxWidth: 55,
                            minWidth: 50,
                            minHeight: 50)),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            Divider(
              color: textColor.withOpacity(.2),
            ),
            const Gap(10),
            MaterialButton(
              onPressed: () async {
                final Position? pos = await _determinePosition();
                if (pos == null) return;
                List<GeoAddress> placemarks =
                    await Geocoder.google().findAddressesFromGeoPoint(
                  GeoPoint(pos.latitude, pos.longitude),
                );
                final String q = placemarks.first.addressLine ?? "";
                // await placeAutocomplete(q);
                setState(() {
                  _search.text = q;
                });
              },
              height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: bgColor.darken(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.location_fill,
                    color: textColor,
                    size: 15,
                  ),
                  const Gap(10),
                  Text(
                    "Use current location",
                    style: TextStyle(color: textColor),
                  )
                ],
              ),
            ),
            const Gap(10),
            Divider(
              color: textColor.withOpacity(.2),
            ),
            const Gap(10),
            if (places.isEmpty) ...{
              SizedBox(
                width: size.width,
                // height: size.height * .3,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_searching_sharp,
                        color: textColor.withOpacity(.2),
                        size: 30,
                      ),
                      const Gap(10),
                      Text(
                        "No location found",
                        style: TextStyle(
                            color: textColor.withOpacity(.2),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            } else ...{
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    final AutocompletePrediction place = places[i];
                    return ListTile(
                      leading: Icon(
                        CupertinoIcons.location_solid,
                        color: orangePalette,
                      ),
                      onTap: () async {
                        final List<GeoAddress> addresses =
                            await Geocoder.google().findAddressesFromQuery(
                                "${place.formatting!.mainText ?? "Unknown"}${place.formatting!.secondaryText == null ? "" : ", ${place.formatting!.secondaryText}"}");
                        print(addresses.first.coordinates);
                        widget.callback(GeoPoint(
                            addresses.first.coordinates!.latitude,
                            addresses.first.coordinates!.longitude));
                      },
                      title: Text(
                        "${place.formatting!.mainText ?? "Unknown"}${place.formatting!.secondaryText == null ? "" : ", ${place.formatting!.secondaryText}"}",
                        style: TextStyle(
                            color: textColor.withOpacity(.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    );
                  },
                  separatorBuilder: (_, i) => Divider(
                        color: textColor.withOpacity(.1),
                      ),
                  itemCount: places.length)
            }
          ],
        ),
      ),
    );
  }

  Future<Position?> _determinePosition() async {
    // if (widget.initLocation != null) {}
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please enable location service");
      return null;
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permissions are denied");
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              "Location permissions are permanently denied, we cannot request permissions.");
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }
}
