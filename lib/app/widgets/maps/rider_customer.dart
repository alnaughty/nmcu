import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/maps/custom_marker.dart';
import 'package:nomnom/app/widgets/maps/pickup_and_destination_map.dart';
import 'package:nomnom/models/user/rider_firestore.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/env_service.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class RiderCustomerMap extends ConsumerStatefulWidget {
  const RiderCustomerMap(
      {super.key,
      required this.riderID,
      required this.riderImage,
      required this.destination, // delivery address
      required this.size,
      required this.riderName,
      this.disableInteraction = false,
      this.onTap});
  final int riderID;
  final String riderImage;
  final String riderName;
  final GeoPoint destination;
  final double size;
  final Function(LatLng)? onTap;
  final bool disableInteraction;
  @override
  ConsumerState<RiderCustomerMap> createState() => _RiderCustomerMapState();
}

class _RiderCustomerMapState extends ConsumerState<RiderCustomerMap>
    with ColorPalette {
  late final Stream<RiderFirestore?> _stream;
  late final StreamSubscription<RiderFirestore?> _streamSubscription;
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  RiderFirestore? riderData;
  listenToRiderLocation() {
    _stream = _firestore.listenSpecificRider(widget.riderID);
    _streamSubscription = _stream.listen((rider) async {
      setState(() {
        riderData = rider;
      });
      if (rider != null) {
        await initPolyline(rider.coordinates);
      }
    });
  }

  BitmapDescriptor? riderMarker;
  BitmapDescriptor? userMarker;
  BitmapDescriptor? destinationMarker;
  Future<BitmapDescriptor> createMarker(
      String picture, String name, Color color) async {
    return await CustomMarkerNom(
      size: 60,
      avatar: picture,
      fullname: name,
      color: color,
    ).toBitmapDescriptor();
  }

  Future<void> initializeMarkerCreator() async {
    riderMarker =
        await createMarker(widget.riderImage, widget.riderName, orangePalette);
    final UserModel? _currentUser = ref.watch(currentUserProvider);
    if (_currentUser != null) {
      userMarker = await createMarker(
        _currentUser.profilePic,
        "My Current Location",
        red,
      );
      destinationMarker = await createMarker(
        _currentUser.profilePic,
        _currentUser.fullname.capitalizeWords(),
        orangePalette,
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      listenToRiderLocation();
      await Future.value([initializeLocation(), initializeMarkerCreator()]);
      // initializeLocation();
      // await initializeMarkerCreator();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  Map<PolylineId, Polyline> polylines = {};

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Future<void> initPolyline(GeoPoint rider) async {
    final EnvService _env = EnvService.instance;
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      // Platform.isAndroid ? "" : "",
      request: PolylineRequest(
        origin: PointLatLng(
            widget.destination.latitude, widget.destination.longitude),
        destination: PointLatLng(
          rider.latitude,
          rider.longitude,
        ),
        mode: TravelMode.driving,
      ),
      googleApiKey: _env.mapApiKey,
    );
    polylineCoordinates =
        result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

    if (mounted) setState(() {});
    _addPolyLine();

    if (mapController != null) {
      final LatLngBounds f = getLatLngBounds([
        LatLng(widget.destination.latitude, widget.destination.longitude),
        LatLng(
          riderData!.coordinates.latitude,
          riderData!.coordinates.longitude,
        )
      ]);
      final double padding = 20.0; // Base padding, can be adjusted as needed
      final double dynamicPadding = padding + (widget.size * 0.15);
      CameraUpdate cu = CameraUpdate.newLatLngBounds(f, dynamicPadding);
      await mapController!.animateCamera(cu);
    }
    // if (result.points.isNotEmpty) {
    //   for (PointLatLng point in result.points) {
    //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    //   }
    //   if (mounted) setState(() {});
    //   _addPolyLine();
    // }
    // print(result.points);
  }

  _addPolyLine() {
    print("ADD POLYLINE");
    PolylineId id =
        PolylineId(DateTime.now().millisecondsSinceEpoch.toString());
    Polyline polyline = Polyline(
      width: 3,
      polylineId: id,
      patterns: [],
      color: orangePalette,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Position? currentPosition;
  Future<void> initializeLocation() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await Geolocator.getCurrentPosition().then(
        (v) async {
          setState(() {
            currentPosition = v;
          });
          print("CURRENT POSITION: $currentPosition");
        },
      );
    } else {
      final perm2 = await Geolocator.requestPermission();
      if (perm2 == LocationPermission.always ||
          perm2 == LocationPermission.whileInUse) {
        // await onGrantedCallback();
        await initializeLocation();
      } else {
        Fluttertoast.showToast(msg: "Please enable location");
        // openAppSettings();
      }
    }
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController? mapController;
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    // final myLocation = ref
    if (currentUser == null && riderData != null) return Container();
    return SizedBox(
      width: double.infinity,
      height: widget.size,
      child: GoogleMap(
        // polygons: {polygon},
        onTap: widget.onTap,
        mapType: MapType.normal,
        scrollGesturesEnabled: !widget.disableInteraction,
        zoomGesturesEnabled: !widget.disableInteraction,
        zoomControlsEnabled: !widget.disableInteraction,
        rotateGesturesEnabled: !widget.disableInteraction,
        buildingsEnabled: !widget.disableInteraction,
        myLocationButtonEnabled: !widget.disableInteraction,
        tiltGesturesEnabled: !widget.disableInteraction,
        layoutDirection: TextDirection.rtl,
        mapToolbarEnabled: !widget.disableInteraction,
        fortyFiveDegreeImageryEnabled: !widget.disableInteraction,
        trafficEnabled: true,
        myLocationEnabled: !widget.disableInteraction,
        liteModeEnabled: Platform.isAndroid,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            riderData!.coordinates.latitude,
            riderData!.coordinates.longitude,
          ),
          zoom: 10,
        ),
        onMapCreated: (GoogleMapController controller) async {
          setState(() {
            mapController = controller;
          });
          _controller.complete(controller);

          final LatLngBounds f = getLatLngBounds([
            LatLng(widget.destination.latitude, widget.destination.longitude),
            LatLng(
              riderData!.coordinates.latitude,
              riderData!.coordinates.longitude,
            )
          ]);
          final double padding =
              20.0; // Base padding, can be adjusted as needed
          final double dynamicPadding = padding + (widget.size * 0.15);
          CameraUpdate cu = CameraUpdate.newLatLngBounds(f, dynamicPadding);
          await controller.animateCamera(cu);
        },
        markers: {
          // if (userMarker != null && currentPosition != null) ...{
          //   Marker(
          //     position:
          //         LatLng(currentPosition!.latitude, currentPosition!.longitude),
          //     markerId: MarkerId("user-marker"),
          //     infoWindow: InfoWindow(
          //       title: "Current location",
          //     ),
          //     icon: userMarker!,
          //   ),
          // },
          if (riderMarker != null && riderData != null) ...{
            Marker(
              position: LatLng(riderData!.coordinates.latitude,
                  riderData!.coordinates.longitude),
              markerId: MarkerId("rider-marker"),
              infoWindow: InfoWindow(
                title: widget.riderName.capitalizeWords(),
              ),
              icon: riderMarker!,
            ),
          },
          if (destinationMarker != null) ...{
            Marker(
              position: LatLng(
                  widget.destination.latitude, widget.destination.longitude),
              markerId: MarkerId("destination-marker"),
              infoWindow: InfoWindow(
                title: currentUser!.fullname.capitalizeWords(),
              ),
              icon: destinationMarker!,
            ),
          }
        },
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  static LatLngBounds getLatLngBounds(List<LatLng> list) {
    double x0 = 0.0;
    double x1 = 0.0;
    double y0 = 0.0;
    double y1 = 0.0;
    for (final latLng in list) {
      if (x0 == 0.0) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }
}
