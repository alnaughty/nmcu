import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/maps/custom_marker.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/env_service.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

// ignore: must_be_immutable
class PickupAndDestMap extends ConsumerStatefulWidget {
  PickupAndDestMap(
      {super.key,
      required this.destination,
      this.disableInteraction = false,
      required this.size,
      this.onTap,
      required this.riderAvatar,
      required this.riderName,
      required this.pickUpLocation});
  GeoPoint destination;
  final double size;
  final bool disableInteraction;
  GeoPoint pickUpLocation;
  final Function(LatLng)? onTap;
  final String riderName;
  final String riderAvatar;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PickupAndDestMapState();
}

class _PickupAndDestMapState extends ConsumerState<PickupAndDestMap>
    with ColorPalette {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.wait([initAddMarker(), initPolyline()]);
    });
    super.initState();
  }

  List<LatLng> boundaryCoordinates = [
    LatLng(12.145200, 124.530700),
    LatLng(12.149400, 124.529000),
    LatLng(12.104200, 124.550600),
    LatLng(12.138800, 124.553400),
    LatLng(12.097900, 124.510800),
    LatLng(12.138300, 124.512300),
    LatLng(12.095100, 124.520300),
    LatLng(12.103800, 124.530800),
    LatLng(12.170700, 124.574500),
    LatLng(12.147300, 124.452700),
    LatLng(12.060000, 124.611900),
    LatLng(12.098300, 124.495100),
    LatLng(12.159900, 124.560700),
    LatLng(12.066670, 124.533330),
    LatLng(12.132500, 124.467300),
    LatLng(12.169400, 124.552700),
    LatLng(12.064300, 124.544200),
    LatLng(12.088000, 124.503700),
    LatLng(12.273060, 124.472500),
    LatLng(12.113700, 124.536000),
    // Add other LatLng points here from your dataset
    LatLng(12.135600, 124.653300),
  ];
  late Polygon polygon = Polygon(
    polygonId: PolygonId("boundary"),
    points: boundaryCoordinates,
    strokeColor: Colors.blue,
    strokeWidth: 2,
    fillColor: Colors.blue.withOpacity(0.1),
  );

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  final EnvService _env = EnvService.instance;
  Future<void> initPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        // Platform.isAndroid ? "" : "",
        googleApiKey: _env.mapApiKey,
        request: PolylineRequest(
            origin: PointLatLng(widget.pickUpLocation.latitude,
                widget.pickUpLocation.longitude),
            destination: PointLatLng(
                widget.destination.latitude, widget.destination.longitude),
            mode: TravelMode.driving,
            optimizeWaypoints: true)
        // travelMode: TravelMode.driving,
        // optimizeWaypoints: true,
        );
    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      if (mounted) setState(() {});
      _addPolyLine();
    }
    // print(result.points);
  }

  Future<void> initAddMarker() async {
    final UserModel? _currentUser = ref.watch(currentUserProvider);
    // final Position? userLoc = ref.watch(coordinateProvider.notifier).state;
    rider = await CustomMarkerNom(
      size: 60,
      avatar: widget.riderAvatar,
      fullname: widget.riderName,
      color: orangePalette,
    ).toBitmapDescriptor();
    me = await CustomMarkerNom(
      size: 60,
      avatar: _currentUser!.profilePic,
      fullname: _currentUser.fullname,
      color: orangePalette,
    ).toBitmapDescriptor();
    // markers.addAll([]);
    if (mounted) setState(() {});
  }

  // LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  //   final Position? userLoc = ref.watch(coordinateProvider.notifier).state;
  //   return LatLngBounds(
  //     northeast:
  //         LatLng(widget.destination!.latitude, widget.riderPoint.longitude),
  //     southwest: LatLng(userLoc!.latitude, userLoc.longitude),
  //   );
  // }
  BitmapDescriptor? rider;
  BitmapDescriptor? me;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final UserModel? _currentUser = ref.watch(currentUserProvider);
    return SizedBox(
      width: double.infinity,
      height: widget.size,
      child: GoogleMap(
        polygons: {polygon},
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
            widget.pickUpLocation.latitude,
            widget.pickUpLocation.longitude,
          ),
          zoom: 20,
        ),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);

          // if (widget.destination == null) {
          //   // controller.animateCamera(cameraUpdate)
          //   await controller.animateCamera(
          //     CameraUpdate.newLatLngZoom(
          //       widget.pickUpLocation != null
          //           ? LatLng(
          //               widget.pickUpLocation!.latitude,
          //               widget.pickUpLocation!.longitude,
          //             )
          //           : LatLng(
          //               userLoc!.latitude,
          //               userLoc.longitude,
          //             ),
          //       20,
          //     ),
          //   );
          //   return;
          // }
          final LatLngBounds f = getLatLngBounds([
            LatLng(widget.destination.latitude, widget.destination.longitude),
            LatLng(
              widget.pickUpLocation.latitude,
              widget.pickUpLocation.longitude,
            )
          ]);
          final double padding =
              20.0; // Base padding, can be adjusted as needed
          final double dynamicPadding = padding + (widget.size * 0.15);
          CameraUpdate cu = CameraUpdate.newLatLngBounds(f, dynamicPadding);
          await controller.animateCamera(cu);
        },
        markers: {
          Marker(
            markerId: MarkerId(_currentUser!.fullname),
            position: LatLng(
              widget.destination.latitude,
              widget.destination.longitude,
            ),
            infoWindow: InfoWindow(
              title: _currentUser.fullname.capitalizeWords(),
            ),
            icon: me ?? BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: MarkerId(widget.riderName.capitalizeWords()),
            position: LatLng(
              widget.pickUpLocation.latitude,
              widget.pickUpLocation.longitude,
            ),
            infoWindow: InfoWindow(
              title: widget.riderName.capitalizeWords(),
            ),
            icon: rider ?? BitmapDescriptor.defaultMarker,
          ),
          // if (widget.destination != null) ...{
          //   Marker(
          //     markerId: const MarkerId("rider"),
          //     position: LatLng(
          //       widget.destination!.latitude,
          //       widget.destination!.longitude,
          //     ),
          //     infoWindow: const InfoWindow(
          //       title: "Destination",
          //     ),
          //     icon: BitmapDescriptor.defaultMarkerWithHue(
          //       BitmapDescriptor.hueBlue,
          //     ),
          //   ),
          // }
        },
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  Future<void> updateCamera() async {
    // final GoogleMapController controller = await _controller.future;

    // await controller
    //     .animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
  }

  _addPolyLine() {
    PolylineId id =
        PolylineId(DateTime.now().millisecondsSinceEpoch.toString());
    Polyline polyline = Polyline(
      width: 4,
      polylineId: id,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      color: orangePalette,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  // void check(CameraUpdate u, GoogleMapController c) async {
  //   final GoogleMapController controller = await _controller.future;
  //   c.animateCamera(u);
  //   controller.animateCamera(u);
  //   LatLngBounds l1 = await c.getVisibleRegion();
  //   LatLngBounds l2 = await c.getVisibleRegion();
  //   print(l1.toString());
  //   print(l2.toString());
  //   if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
  //     check(u, c);
  // }
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
