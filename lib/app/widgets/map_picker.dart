import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_picker/map_picker.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/picker_pin.dart';
import 'package:nomnom/app/widgets/search_map.dart';
import 'package:nomnom/models/geocoder/geoaddress.dart';
import 'package:nomnom/services/geocoder_services/geocoder.dart';

class NomNomMapPicker extends ConsumerStatefulWidget {
  const NomNomMapPicker(
      {super.key, required this.geoPointCallback, this.initLocation});
  final ValueChanged<GeoPoint> geoPointCallback;
  final GeoPoint? initLocation;
  @override
  ConsumerState<NomNomMapPicker> createState() => _NomNomMapPickerState();
}

class _NomNomMapPickerState extends ConsumerState<NomNomMapPicker>
    with ColorPalette {
  bool showLocation = true;
  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();
  final TextEditingController textController = TextEditingController();
  GoogleMapController? mapController;
  CameraPosition? cameraPosition;
  Future<Position?> _determinePosition() async {
    if (widget.initLocation != null) {}
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

  void _showMyLocation() async {
    final Position? position = await _determinePosition();
    if (position == null) return;

    final GoogleMapController controller = await _controller.future;
    setState(() {
      cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 18,
      );
    });

    controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition!),
    );

    // Update textController with the new location address if needed
    // You can fetch and display the address here using Geocoder
    // For demonstration, updating with a placeholder address
    textController.text =
        "Current Location: ${position.latitude}, ${position.longitude}";
  }

  // late String _mapStyleString;
  @override
  void initState() {
    // TODO: implement initState
    // _places = ;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = scaffoldColor;
    final Color textColor = darkGrey;
    // final Position? userLoc = ref.watch(coordinateProvider.notifier).state;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          MapPicker(
            // pass icon widget
            iconWidget: PickerPin(
              size: 50,
            ),
            // iconWidget: Image.asset(
            //   "assets/icons/party-location.gif",
            //   height: 60,
            //   color: purplePalette,
            // ),
            // iconWidget: SvgPicture.asset(
            //   "assets/icons/location.svg",
            //   color: purplePalette,
            //   height: 60,
            // ),

            //add map picker controller
            mapPickerController: mapPickerController,
            child: GoogleMap(
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              // compassEnabled: true,
              // hide location button
              // minMaxZoomPreference: MinMaxZoomPreference.unbounded,
              myLocationButtonEnabled: false,
              // mapToolbarEnabled: true,
              mapType: MapType.normal,
              //  camera position
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.initLocation!.latitude,
                    widget.initLocation!.longitude),
                zoom: 20,
              ),
              onMapCreated: (GoogleMapController controller) async {
                setState(() {
                  mapController = controller;
                });
                _controller.complete(controller);
                // final bool darkMode = ref.watch(darkModeProvider);

                // if (darkMode) {
                //   await _controller.future.then((value) async {
                //     final String f =
                //         await rootBundle.loadString('map_dark_mode.json');
                //     value.setMapStyle(f);
                //   });
                // }
                // await showPredictions();
                setState(() {
                  cameraPosition = CameraPosition(
                    target: LatLng(widget.initLocation!.latitude,
                        widget.initLocation!.longitude),
                    zoom: 20,
                  );
                });
              },
              onCameraMoveStarted: () {
                // notify map is moving
                mapPickerController.mapMoving!();
                textController.text = "checking ...";
                setState(() {
                  showLocation = false;
                });
              },
              onCameraMove: (c) {
                cameraPosition = c;
              },
              onCameraIdle: () async {
                // notify map stopped moving
                mapPickerController.mapFinishedMoving!();
                //get address name from camera position
                List<GeoAddress> placemarks =
                    await Geocoder.google().findAddressesFromGeoPoint(
                  GeoPoint(cameraPosition!.target.latitude,
                      cameraPosition!.target.longitude),
                );
                setState(() {
                  showLocation = true;
                });
                // update the ui with the address
                textController.text =
                    '${placemarks.first.featureName}, ${placemarks.first.locality}, ${placemarks.first.countryName}';
              },
            ),
          ),
          // Positioned(
          //   top: MediaQuery.of(context).viewPadding.top + 20,
          //   width: MediaQuery.of(context).size.width - 50,
          //   // height: 50,
          //   child: AnimatedContainer(
          //     duration: 1000.ms,
          //     decoration: BoxDecoration(
          //         color: showLocation
          //             ? purplePalette.withOpacity(.2)
          //             : Colors.transparent,
          //         borderRadius: BorderRadius.circular(60)),
          //     padding: const EdgeInsets.all(15),
          //     child: Text(
          //       textController.text,
          //       style: TextStyle(
          //         color: showLocation ? Colors.grey.shade900 : purplePalette,
          //       ),
          //     ),
          //     // child: TextFormField(
          //     //   textAlign: TextAlign.center,
          //     //   readOnly: true,
          //     //   keyboardType: TextInputType.multiline,
          //     //   maxLines: null,
          //     //   decoration: const InputDecoration(
          //     //       contentPadding: EdgeInsets.zero, border: InputBorder.none),
          //     //   controller: textController,
          //     // ),
          //   ),
          // ),
          // Positioned(
          //   top: 0,
          //   left: 20,
          //   child: SafeArea(
          //       child: BackButton(
          //     style: ButtonStyle(
          //       shadowColor:
          //           WidgetStateProperty.resolveWith((states) => Colors.grey),
          //       elevation: WidgetStateProperty.resolveWith((states) => 1),
          //       // fixedSize: WidgetStateProperty.resolveWith(
          //       //     (states) => const Size(65, 65)),
          //       backgroundColor: WidgetStateProperty.resolveWith(
          //           (states) => bgColor.lighten()),
          //       foregroundColor:
          //           WidgetStateProperty.resolveWith((s) => textColor),
          //       shape: WidgetStateProperty.resolveWith(
          //         (states) => RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(200),
          //         ),
          //       ),
          //     ),
          //     color: Colors.grey.shade800,
          //     onPressed: () {
          // if (context.canPop()) {
          //   context.pop();
          // }
          //     },
          //   ),),
          // ),
          Positioned(
            top: 0,
            left: 15,
            child: SafeArea(
              child: IconButton.filled(
                style: ButtonStyle(
                  shadowColor:
                      WidgetStateProperty.resolveWith((states) => Colors.grey),
                  elevation: WidgetStateProperty.resolveWith((states) => 1),
                  // fixedSize: WidgetStateProperty.resolveWith(
                  //     (states) => const Size(65, 65)),
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => bgColor.lighten()),
                  // padding: WidgetStateProperty.resolveWith(
                  //     (s) => EdgeInsets.zero),
                  // fixedSize: WidgetStateProperty.resolveWith(
                  //     (s) => Size.fromHeight(20)),
                  foregroundColor:
                      WidgetStateProperty.resolveWith((s) => textColor),
                  shape: WidgetStateProperty.resolveWith(
                    (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200),
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                icon: Center(
                  child: Icon(
                    Platform.isIOS
                        ? Icons.arrow_back_ios_new
                        : Icons.arrow_back,
                    size: 15,
                    color: textColor,
                  ),
                ),
                // icon: SvgPicture.asset(
                //   "assets/icons/back.svg",
                //   color: textColor,
                //   height: 15,
                // ),
                // icon: Icon(
                //   Platform.isIOS
                //       ? CupertinoIcons.back
                //       : Icons.keyboard_backspace_rounded,
                //   size: 20,
                // ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 15,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton.filled(
                    style: ButtonStyle(
                      shadowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.grey),
                      elevation: WidgetStateProperty.resolveWith((states) => 1),
                      // fixedSize: WidgetStateProperty.resolveWith(
                      //     (states) => const Size(65, 65)),
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => bgColor.lighten()),
                      // padding: WidgetStateProperty.resolveWith(
                      //     (s) => EdgeInsets.zero),
                      // fixedSize: WidgetStateProperty.resolveWith(
                      //     (s) => Size.fromHeight(20)),
                      foregroundColor:
                          WidgetStateProperty.resolveWith((s) => textColor),
                      shape: WidgetStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchMap(callback: (callback) async {
                            Navigator.of(context).pop();
                            // await Future.delayed(1.seconds);
                            // // ignore: use_build_context_synchronously
                            // Navigator.of(context).pop();
                            // widget.geoPointCallback(
                            //   GeoPoint(
                            //     cameraPosition!.target.latitude,
                            //     cameraPosition!.target.longitude,
                            //   ),
                            // );
                            // final Position? position =
                            //     await _determinePosition();
                            // if (position == null) return;

                            final GoogleMapController controller =
                                await _controller.future;
                            setState(() {
                              cameraPosition = CameraPosition(
                                target: LatLng(
                                    callback.latitude, callback.longitude),
                                zoom: 18,
                              );
                            });

                            controller.animateCamera(
                              CameraUpdate.newCameraPosition(cameraPosition!),
                            );

                            // Update textController with the new location address if needed
                            // You can fetch and display the address here using Geocoder
                            // For demonstration, updating with a placeholder address
                            textController.text =
                                "Current Location: ${callback.latitude}, ${callback.longitude}";
                          }),
                        ),
                      );
                    },
                    icon: const Icon(
                      CupertinoIcons.search,
                      size: 16,
                    ),
                  ),
                  const Gap(5),
                  IconButton.filled(
                    style: ButtonStyle(
                      shadowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.grey),
                      elevation: WidgetStateProperty.resolveWith((states) => 1),
                      // fixedSize: WidgetStateProperty.resolveWith(
                      //     (states) => const Size(65, 65)),
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => bgColor.lighten()),
                      // padding: WidgetStateProperty.resolveWith(
                      //     (s) => EdgeInsets.zero),
                      // fixedSize: WidgetStateProperty.resolveWith(
                      //     (s) => Size.fromHeight(20)),
                      foregroundColor:
                          WidgetStateProperty.resolveWith((s) => textColor),
                      shape: WidgetStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    onPressed: _showMyLocation,
                    icon: const Icon(
                      CupertinoIcons.location_fill,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Card(
                    color: bgColor.lighten(),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            // if (showLocation) ...{
                            //   // Image.asset(
                            //   //   "assets/images/mockup_vectors/location.png",
                            //   //   width: 50,
                            //   // ),
                            //   // const Gap(10)
                            // },
                            Expanded(
                              child: Text(
                                textController.text.isEmpty
                                    ? "No location pinned"
                                    : textController.text,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.all(15),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white
                  //   ),
                  // ),
                  MaterialButton(
                    height: 60,
                    color: orangePalette,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.geoPointCallback(
                        GeoPoint(
                          cameraPosition!.target.latitude,
                          cameraPosition!.target.longitude,
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // child: SizedBox(
            //   height: 50,
            //   child: TextButton(
            //     onPressed: () {
            //       // print(
            //       //     "Location ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}");
            //       //
            //     },
            //     style: ButtonStyle(
            //       backgroundColor:
            //           MaterialStateProperty.all<Color>(const Color(0xFFA3080C)),
            //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //         RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(15.0),
            //         ),
            //       ),
            //     ),
            //     child: const Text(
            //       "Submit",
            //       style: TextStyle(
            //         fontWeight: FontWeight.w400,
            //         fontStyle: FontStyle.normal,
            //         color: Color(0xFFFFFFFF),
            //         fontSize: 19,
            //         // height: 19/19,
            //       ),
            //     ),
            //   ),
            // ),
          )
        ],
      ),
    );
  }

  // late final plc.FlutterGooglePlacesSdk _places = plc.FlutterGooglePlacesSdk(
  //   _env.mapApiKey,
  //   locale: const Locale('en', 'AU'),
  // );
  // final List<plc.PlaceField> _placeFields = const [
  //   plc.PlaceField.Address,
  //   plc.PlaceField.AddressComponents,
  //   plc.PlaceField.BusinessStatus,
  //   plc.PlaceField.Id,
  //   plc.PlaceField.Location,
  //   plc.PlaceField.Name,
  //   plc.PlaceField.OpeningHours,
  //   plc.PlaceField.PhoneNumber,
  //   plc.PlaceField.PhotoMetadatas,
  //   plc.PlaceField.PlusCode,
  //   plc.PlaceField.PriceLevel,
  //   plc.PlaceField.Rating,
  //   plc.PlaceField.Types,
  //   plc.PlaceField.UserRatingsTotal,
  //   plc.PlaceField.UTCOffset,
  //   plc.PlaceField.Viewport,
  //   plc.PlaceField.WebsiteUri,
  // ];
  Future<void> showPredictions() async {
    // await _places.
    // await _places.isInitialized().then((value) {
    //   print("PLACES INITIALIZED");
    // });
    // final Prediction?
  }
}
