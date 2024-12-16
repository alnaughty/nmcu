import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/date_ext.dart';
import 'package:nomnom/app/extensions/geo_point_ext.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/extensions/time_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/maps/full_screen_map.dart';
import 'package:nomnom/app/widgets/maps/pickup_and_destination_map.dart';
import 'package:nomnom/app/widgets/maps/rider_customer.dart';
import 'package:nomnom/app/widgets/vertical_dash_divider.dart';
import 'package:nomnom/models/cart/order_model.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/user/rider_firestore.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/order_api.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/views/navigation_children/chatroom_page.dart';
import 'package:nomnom/views/navigation_children/rate_delivered_order_page.dart';

class TrackOrderPage extends ConsumerStatefulWidget {
  const TrackOrderPage({super.key, required this.id});
  final int id;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends ConsumerState<TrackOrderPage>
    with ColorPalette {
  final DateFormat format = DateFormat('dd MMM, hh:mm');
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  late StreamSubscription<DeliveryModel?> _deliverySubscription;
  late final Stream<DeliveryModel?> deliveryStream;
  StreamSubscription<RiderFirestore?>? _riderPositionSubscription;
  double calculateETA(double distance, double speed) {
    // ETA = Distance / Speed
    // Speed is assumed in km/h, so ETA will be in hours
    return ((distance / speed) * 1000);
  }

  // Stream<RiderFirestore> r
  final OrderApi _api = OrderApi();
  DeliveryModel? model;
  RiderFirestore? assignedRider;
  late final detailsProvider = FutureProvider<OrderModel?>((ref) async {
    final result = await _api.getDetails(widget.id);
    if (result != null) {
      deliveryStream =
          _firestore.listenToSpecificItem(referenceCode: result.reference);
      _deliverySubscription = deliveryStream.listen((d) {
        setState(() {
          model = d;
        });
        if (d == null) return;
        if (_riderPositionSubscription == null &&
            d.rider != null &&
            (d.status > 2 && d.status <= 4)) {
          _riderPositionSubscription =
              _firestore.listenSpecificRider(d.rider!.id).listen((rr) async {
            setState(() {
              assignedRider = rr;
            });
            final nEta = calculateETA(
                rr!.coordinates
                    .calculateDistance(model!.destination.coordinates),
                rr.speed < 20 ? 30 : rr.speed);
            await _firestore.updateETA(model!.reference, nEta);
            print(rr.coordinates.convertString());
            print(nEta);
          });
        }
      });
    } else {
      print("NULL VALUE");
    }
    return result;
  });
  customTile({required String title, String? subtitle, Widget? leading}) => Row(
        children: [
          if (leading != null) ...{
            leading,
            const Gap(10),
          },
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...{
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: grey,
                    ),
                  )
                },
              ],
            ),
          )
        ],
      );
  customStep(
      {required IconData icon,
      required String title,
      required Widget child,
      required bool isEnabled,
      double height = 66,
      double dividerWidth = 33,
      double sizePercent = 1}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isEnabled ? orangePalette : grey,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const Gap(15),
            Text(
              title,
              style: TextStyle(
                  fontSize: 13 * sizePercent, fontWeight: FontWeight.w500),
            )
          ],
        ),
        const Gap(10),
        SizedBox(
          height: height,
          width: double.infinity,
          child: Row(
            children: [
              SizedBox(
                width: dividerWidth,
                child: Center(
                  child: VerticalDashDivider(
                    height: height,
                    color: grey,
                  ),
                ),
              ),
              const Gap(15),
              Expanded(child: child),
            ],
          ),
        )
      ],
    );
  }

  customStepV2({
    required Widget icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      children: [
        Row(
          children: [
            icon,
            const Gap(15),
            Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            )
          ],
        ),
        const Gap(10),
        Row(
          children: [
            SizedBox(
              width: 32,
              // child: Center(
              //   child: VerticalDashDivider(
              //     height: 66,
              //     color: grey,
              //   ),
              // ),
            ),
            const Gap(15),
            Expanded(child: child),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_){
    //   initStream();
    // });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _deliverySubscription.cancel();
    _riderPositionSubscription?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  final loadingProvider = StateProvider<bool>((ref) => false);
  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(loadingProvider);
    final result = ref.watch(detailsProvider);
    final Size size = MediaQuery.of(context).size;
    final UserModel? currentUser = ref.watch(currentUserProvider);
    return result.when(
        data: (data) {
          if (data == null || model == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Something went wrong"),
              ),
            );
          }
          return PopScope(
            canPop: !isLoading,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Scaffold(
                      backgroundColor: subScaffoldColor,
                      body: Column(
                        children: [
                          Container(
                            color: orangePalette,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    "assets/images/vector_background.png",
                                    fit: BoxFit.cover,
                                    color: Colors.white.withOpacity(.5),
                                  ),
                                ),
                                Column(
                                  children: [
                                    PreferredSize(
                                      preferredSize: Size.fromHeight(56),
                                      child: AppBar(
                                        iconTheme: IconThemeData(
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        centerTitle: true,
                                        title: Text(
                                          model!.status > 4
                                              ? "Thank you"
                                              : "Order Status",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: model!.status == 5
                                ? RateDeliveredOrderPage(
                                    model: model!,
                                    loadingProvider: loadingProvider,
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                "assets/images/rider.png",
                                                width: 80,
                                              ),
                                              const Gap(20),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    if (model!.status == 1 &&
                                                        model!.prepTime !=
                                                            null) ...{
                                                      customTile(
                                                        leading: Icon(
                                                          Icons.access_time,
                                                          color: orangePalette,
                                                        ),
                                                        title:
                                                            "${model!.prepTime!.difference(DateTime.now()).inMinutes} min",
                                                        subtitle:
                                                            "Preparing your order",
                                                      ),
                                                    } else ...{
                                                      customTile(
                                                        leading: Icon(
                                                          Icons.access_time,
                                                          color: orangePalette,
                                                        ),
                                                        title: model!.eta < 2
                                                            ? "Anytime now"
                                                            : "${model!.eta.ceil().toString()} min",
                                                        subtitle:
                                                            "Estimated delivery",
                                                      ),
                                                    },
                                                    const Gap(10),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          color: orangePalette,
                                                        ),
                                                        const Gap(10),
                                                        Expanded(
                                                          child: Text(
                                                            model!.destination
                                                                .address,
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const Gap(10),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Order #${model!.reference}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Gap(15),
                                              customStep(
                                                icon: Icons.person,
                                                title: "Assigned rider",
                                                child: model!.rider == null
                                                    ? SizedBox(
                                                        width:
                                                            size.width - (88),
                                                        child: CustomLoader(
                                                          color: darkGrey,
                                                          label:
                                                              "Waiting for rider to accept",
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width:
                                                            size.width - (88),
                                                        child: Row(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    "https://back.nomnomdelivery.com${model!.rider!.photoUrl}",
                                                                height: 50,
                                                                width: 50,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            const Gap(10),
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    model!
                                                                        .rider!
                                                                        .fullname
                                                                        .capitalizeWords(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "Nom nom rider",
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          orangePalette,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () async {
                                                                // await _firestore.createChatroom(
                                                                //     refcode: model!.reference);

                                                                Navigator.push(
                                                                  // ignore: use_build_context_synchronously
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ChatroomPage(
                                                                      receiverID:
                                                                          model!
                                                                              .rider!
                                                                              .id,
                                                                      reference:
                                                                          model!
                                                                              .reference,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .chat_bubble,
                                                                    color:
                                                                        orangePalette,
                                                                  ),
                                                                  const Gap(5),
                                                                  Text(
                                                                    "Chat rider",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                isEnabled: model!.rider != null,
                                              ),
                                              const Gap(15),
                                              customStep(
                                                icon: Icons.access_time,
                                                title: "Waiting for restaurant",
                                                child: SizedBox(
                                                    width: size.width - (88),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          model!.merchant.name
                                                              .capitalizeWords(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.access_time,
                                                              color:
                                                                  orangePalette,
                                                              size: 15,
                                                            ),
                                                            const Gap(10),
                                                            Text(
                                                              format.format(
                                                                model!
                                                                    .deliveryTime
                                                                    .toDateTime(
                                                                        date: model!
                                                                            .deliveryDate),
                                                              ),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                                isEnabled: model!.status > 0,
                                              ),
                                              const Gap(15),
                                              customStep(
                                                icon: Icons.access_time,
                                                title: "Order received",
                                                child: SizedBox(
                                                    width: size.width - (88),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          model!.merchant.name
                                                              .capitalizeWords(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.access_time,
                                                              color:
                                                                  orangePalette,
                                                              size: 15,
                                                            ),
                                                            const Gap(10),
                                                            Text(
                                                              format.format(
                                                                model!
                                                                    .deliveryTime
                                                                    .toDateTime(
                                                                        date: model!
                                                                            .deliveryDate),
                                                              ),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                                isEnabled: model!.status >= 1,
                                              ),
                                              const Gap(15),
                                              customStepV2(
                                                icon: Container(
                                                  decoration: BoxDecoration(
                                                    color: model!.status > 2
                                                        ? orangePalette
                                                        : grey,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: ImageIcon(
                                                    AssetImage(
                                                      "assets/icons/rider_icon.png",
                                                    ),
                                                    color: Colors.white,
                                                    size: 17,
                                                  ),
                                                  // child: Icon(
                                                  //   icon,
                                                  //   color: Colors.white,
                                                  // ),
                                                ),
                                                title: "Status",
                                                child: Column(
                                                  children: [
                                                    customStep(
                                                      icon: Icons.check,
                                                      title: "Picked-up",
                                                      sizePercent: 1.2,
                                                      height: 30,
                                                      child: Text(
                                                        "Arrived at shop, and picked-up your order",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      isEnabled:
                                                          model!.status > 2,
                                                    ),
                                                    const Gap(10),
                                                    customStep(
                                                      icon: Icons.check,
                                                      title: "Arrived",
                                                      sizePercent: 1.2,
                                                      height: 35,
                                                      child: Text(
                                                        "Arrived at your location, please prepare payment if there is",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      isEnabled:
                                                          model!.status > 3,
                                                    ),
                                                    const Gap(10),
                                                    customStep(
                                                      icon: Icons.check,
                                                      title: "Delivered",
                                                      sizePercent: 1.2,
                                                      height: 35,
                                                      child: Text(
                                                        "Order is completed, thank your for trusting us.",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      isEnabled:
                                                          model!.status > 4,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        if (assignedRider != null &&
                                            model!.status > 2 &&
                                            model!.status < 5) ...{
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Hero(
                                                tag: model!.reference,
                                                child: RiderCustomerMap(
                                                  size: 200,
                                                  riderID: model!.rider!.id,
                                                  riderImage:
                                                      "https://back.nomnomdelivery.com${model!.rider!.photoUrl}",
                                                  destination: model!
                                                      .destination.coordinates,
                                                  onTap: (latlng) async {
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullScreenMap(
                                                            riderID: model!
                                                                .rider!.id,
                                                            riderImage:
                                                                "https://back.nomnomdelivery.com${model!.rider!.photoUrl}",
                                                            destination: model!
                                                                .destination
                                                                .coordinates,
                                                            heroTag: model!
                                                                .reference,
                                                            riderName: model!
                                                                .rider!
                                                                .fullname,
                                                          ),
                                                        ));
                                                  },
                                                  riderName:
                                                      model!.rider!.fullname,
                                                  disableInteraction: true,
                                                ),
                                                // child: PickupAndDestMap(
                                                //   onTap: (f) {
                                                //     Navigator.push(
                                                //       context,
                                                //       MaterialPageRoute(
                                                //         builder: (context) => FullScreenMap(
                                                //           riderName: model!.rider!.fullname,
                                                //           riderPhotoUrl:
                                                //               "https://back.nomnomdelivery.com${model!.rider!.photoUrl}",
                                                //           dest: model!.destination.coordinates,
                                                //           pickup: assignedRider!.coordinates,
                                                //         ),
                                                //       ),
                                                //     );
                                                //   },
                                                //   riderName: model!.rider!.fullname,
                                                //   riderAvatar:
                                                //       "https://back.nomnomdelivery.com${model!.rider!.photoUrl}",
                                                //   disableInteraction: true,
                                                //   destination: model!.destination.coordinates,
                                                //   size: 200,
                                                //   pickUpLocation: assignedRider!.coordinates,
                                                // ),
                                              ),
                                            ),
                                          ),
                                          SafeArea(
                                              top: false, child: SizedBox())
                                        },
                                      ],
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (isLoading) ...{
                    Positioned.fill(
                      child: Material(
                        color: Colors.black.withOpacity(.5),
                        child: Center(
                          child: CustomLoader(
                            label: "Submitting review",
                          ),
                        ),
                      ),
                    )
                  },
                ],
              ),
            ),
          );
        },
        error: (error, s) => Scaffold(
              appBar: AppBar(
                title: Text("Something went wrong"),
              ),
            ),
        loading: () => Scaffold(
              appBar: AppBar(),
              body: Center(
                child: CustomLoader(
                  label: "Fetching order details",
                  color: darkGrey,
                ),
              ),
            ));
  }
}
