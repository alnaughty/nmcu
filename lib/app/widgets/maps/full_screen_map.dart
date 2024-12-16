import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/maps/pickup_and_destination_map.dart';
import 'package:nomnom/app/widgets/maps/rider_customer.dart';

class FullScreenMap extends StatefulWidget {
  const FullScreenMap({
    super.key,
    required this.riderID,
    required this.riderImage,
    required this.destination, //
    required this.riderName,
    required this.heroTag,
    this.disableInteraction = false,
  });
  final String heroTag;
  final int riderID;
  final String riderImage;
  final String riderName;
  final GeoPoint destination;
  final bool disableInteraction;
  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> with ColorPalette {
  // late final PickupAndDestMap map = ;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: widget.heroTag,
              child: RiderCustomerMap(
                riderID: widget.riderID,
                riderImage: widget.riderImage,
                destination: widget.destination,
                size: size.height,
                riderName: widget.riderName,
              ),
              // child: PickupAndDestMap(
              //   riderName: widget.riderName,
              //   riderAvatar: widget.riderPhotoUrl,
              //   destination: widget.dest,
              //   size: MediaQuery.of(context).size.height,
              //   pickUpLocation: widget.pickup,
              // ),
            ),
          ),
          Positioned(
            left: 10,
            top: 20,
            child: SafeArea(child: BackButton()),
          ),
        ],
      ),
    );
  }
}
