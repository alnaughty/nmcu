import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/geo_point_ext.dart';
import 'package:nomnom/app/extensions/list_ext.dart';
import 'package:nomnom/app/extensions/time_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/dashed_divider.dart';
import 'package:nomnom/app/widgets/map_picker.dart';
import 'package:nomnom/models/cart/cart_item.dart';
import 'package:nomnom/models/geocoder/geoaddress.dart';
import 'package:nomnom/models/user/current_address.dart';
import 'package:nomnom/models/user/rider_firestore.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/cart_api.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/services/geocoder_services/geocoder.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/cart_menu_listing.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/checkout_page_children/use_nomnom_coins.dart';

class PlaceOrderForFriendPage extends ConsumerStatefulWidget {
  const PlaceOrderForFriendPage({super.key, required this.data});
  final CheckoutData data;
  @override
  ConsumerState<PlaceOrderForFriendPage> createState() =>
      _PlaceOrderForFriendPageState();
}

class _PlaceOrderForFriendPageState
    extends ConsumerState<PlaceOrderForFriendPage> with ColorPalette {
  int nomnomPointsUsed = 0;
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _brgy = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final CartApi _api = CartApi();
  late DeliveryType delType = widget.data.deliveryType;
  late DateTime deliveryDate = widget.data.deliveryDate;
  late TimeOfDay deliveryTime = widget.data.deliveryTime;
  late bool isPreorder = widget.data.isPreorder;
  bool isFriendPay = false;
  Widget summaryBuilder({required String title, required String value}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: "",
            ),
          )
        ],
      );
  int calculateAverageETA({
    required UserAddress deliveryAddress,
    required GeoPoint store,
    double speed = 30,
  }) {
    // if (stores.isEmpty) {
    //   throw ArgumentError("At least one store is required.");
    // }
    double totalDistance = 0.0;
    double distance =
        store.calculateETAMinutes(deliveryAddress.coordinates, speed: speed);
    totalDistance += distance;
    // for (var store in stores) {

    // }
    double averageDistance = totalDistance;
    return calculateETA(averageDistance, speed);
  }

  int calculateETA(double distance, double speed) {
    // ETA = Distance / Speed
    // Speed is assumed in km/h, so ETA will be in hours
    return ((distance / speed) * 1000).ceil();
  }

  Future<void> checkLocation(GeoPoint point) async {
    final List<GeoAddress> addresses =
        await Geocoder.google().findAddressesFromGeoPoint(point);
    print(addresses);
    final GeoAddress first = addresses.first;
    final c = CurrentAddress(
      addressLine: first.addressLine ?? "",
      city: first.locality ?? "",
      coordinates: point,
      locality: first.subLocality ?? "",
      countryCode: first.countryCode ?? "",
      country: first.countryName ?? "",
      barangay: first.subLocality ?? "",
      region: first.adminArea ?? "",
      state: first.subAdminArea ?? "",
      street: first.thoroughfare ?? "",
    ).toUserAddress();
    setState(() {
      deliveryAddress = c;
      _address.text = first.addressLine ?? "";
      _brgy.text = first.subLocality ?? "";
      _city.text = first.locality ?? "";
      _country.text = first.countryName ?? "";
      _state.text = first.subAdminArea ?? "";
      _region.text = first.adminArea ?? '';
      _street.text = first.thoroughfare ?? "";
      editableField = true;
    });
  }

  final List<String> paymentOptionPayor = ["I will pay", "My friend will pay"];

  bool editableField = false;
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  Widget titler({required String label, required Widget icon}) => Row(
        children: [
          icon,
          const Gap(10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          )
        ],
      );
  UserAddress? deliveryAddress;
  @override
  Widget build(BuildContext context) {
    final myLocation = ref.watch(currentLocationProvider);
    final currentUser = ref.watch(currentUserProvider);
    // final initLocation = selectedLocation;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Friend's information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Gap(15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  child: Form(
                    key: _kForm,
                    child: Column(
                      children: [
                        titler(
                          label: "Friend's address",
                          icon: ImageIcon(
                            AssetImage("assets/icons/location.png"),
                            color: orangePalette,
                          ),
                        ),
                        const Gap(15),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _name,
                                style: TextStyle(fontSize: 13),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "First name",
                                  hintText: "First name",
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(fontSize: 13),
                                controller: _lastname,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "Last name",
                                  hintText: "Last name",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        TextFormField(
                          style: TextStyle(fontSize: 13),
                          controller: _phone,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: "Mobile number",
                              hintText: "9XXXXXXX",
                              prefix: Text("+63")),
                        ),
                        if (myLocation != null) ...{
                          const Gap(10),
                          MaterialButton(
                            height: 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(
                                    color: orangePalette, width: 1.5)),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, a1, a2) =>
                                        NomNomMapPicker(
                                            initLocation:
                                                deliveryAddress?.coordinates ??
                                                    myLocation.coordinates,
                                            geoPointCallback: (geo) async {
                                              // setState(() {
                                              //   coordinates = geo;
                                              // });

                                              // setState(() {
                                              //   myPosition = geo;
                                              // });
                                              await checkLocation(geo);
                                            })),
                              );
                            },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ImageIcon(
                                    AssetImage("assets/icons/location.png"),
                                    color: orangePalette,
                                  ),
                                  const Gap(10),
                                  Text(
                                    deliveryAddress == null
                                        ? "Select location"
                                        : "Re-select location",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: orangePalette,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        },
                        const Gap(10),
                        TextFormField(
                          enabled: editableField,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          controller: _address,
                          decoration: const InputDecoration(
                            labelText: "Address",
                            hintText: "Street name, Building, House no.",
                          ),
                        ),
                        const Gap(15),
                        TextFormField(
                          enabled: editableField,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          controller: _street,
                          decoration: const InputDecoration(
                            labelText: "Street",
                            hintText: "Street name etc.",
                          ),
                        ),
                        const Gap(15),
                        TextFormField(
                          enabled: editableField,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          controller: _brgy,
                          decoration: const InputDecoration(
                            labelText: "Barangay",
                            hintText: "Barangay",
                          ),
                        ),
                        const Gap(15),
                        TextFormField(
                          enabled: false,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          controller: _city,
                          decoration: const InputDecoration(
                            labelText: "City",
                            hintText: "City",
                          ),
                        ),
                        const Gap(15),
                        TextFormField(
                          enabled: false,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          controller: _state,
                          decoration: const InputDecoration(
                            labelText: "State",
                            hintText: "State",
                          ),
                        ),
                        const Gap(15),
                        TextFormField(
                          enabled: false,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          controller: _region,
                          decoration: const InputDecoration(
                            labelText: "Region",
                            hintText: "Region",
                          ),
                        ),
                        const Gap(15),
                        TextFormField(
                          enabled: false,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                          controller: _country,
                          decoration: const InputDecoration(
                            labelText: "Country",
                            hintText: "Country",
                          ),
                        ),
                        const Gap(15),
                        TextFormField(
                          enabled: true,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          controller: _landmark,
                          decoration: const InputDecoration(
                            labelText: "Landmark (Optional)",
                            hintText: "Place near you",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ImageIcon(
                            AssetImage("assets/icons/card.png"),
                            color: orangePalette,
                            size: 15,
                          ),
                          const Gap(10),
                          Text(
                            "Payment Options",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const Gap(15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Cash",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "₱ ${widget.data.pricing.total.ceil().toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "",
                            ),
                          )
                        ],
                      ),
                      DashedDivider(
                        color: textField,
                      ),
                      Row(
                        children: paymentOptionPayor
                            .map(
                              (e) => Expanded(
                                child: MaterialButton(
                                  height: 45,
                                  onPressed: () {
                                    int index = paymentOptionPayor.indexOf(e);
                                    if (index == 0) {
                                      isFriendPay = false;
                                    } else {
                                      isFriendPay = true;
                                    }
                                    setState(() {});
                                  },
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                        color: isFriendPay &&
                                                    paymentOptionPayor
                                                            .indexOf(e) ==
                                                        1 ||
                                                !isFriendPay &&
                                                    paymentOptionPayor
                                                            .indexOf(e) ==
                                                        0
                                            ? orangePalette.withOpacity(1)
                                            : Colors.transparent,
                                        width: 1.5),
                                  ),
                                  color: isFriendPay &&
                                              paymentOptionPayor.indexOf(e) ==
                                                  1 ||
                                          !isFriendPay &&
                                              paymentOptionPayor.indexOf(e) == 0
                                      ? orangePalette.withOpacity(.5)
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ),
                ),
                const Gap(15),
                UseNomnomCoins(pointsCallback: (p) {
                  setState(() {
                    nomnomPointsUsed = p;
                  });
                }),
                const Gap(15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      titler(
                        label: "Order summary",
                        icon: ImageIcon(
                          AssetImage("assets/icons/receipt.png"),
                          size: 15,
                          color: orangePalette,
                        ),
                      ),
                      const Gap(15),
                      ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final CartItem itm = widget.data.cart.items[i];
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${itm.quantity}x ${itm.menuName}",
                                ),
                              ),
                              const Gap(10),
                              Text(
                                "₱ ${itm.subtotal}",
                                style: TextStyle(
                                  fontFamily: "",
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          );
                        },
                        separatorBuilder: (_, i) => DashedDivider(
                          color: textField,
                          dashHeight: 1.5,
                        ),
                        itemCount: widget.data.cart.items.length,
                      ),
                      const Gap(10),
                      Divider(
                        color: textField,
                      ),

                      /// SUMMARY
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          summaryBuilder(
                            title: "Subtotal",
                            value:
                                "₱ ${widget.data.pricing.subtotal.ceil().toStringAsFixed(2)}",
                          ),
                          const Gap(10),
                          summaryBuilder(
                              title: "Delivery Fee",
                              value:
                                  "₱ ${widget.data.pricing.deliveryFee.ceil().toStringAsFixed(2)}"),
                          if (widget.data.pricing.promoDeduction > 0) ...{
                            const Gap(10),
                            summaryBuilder(
                                title: "Discount",
                                value:
                                    "- ₱ ${widget.data.pricing.promoDeduction.toStringAsFixed(2)}"),
                          },
                          if (nomnomPointsUsed > 0) ...{
                            const Gap(10),
                            summaryBuilder(
                                title: "Nomnom Points",
                                value:
                                    "- ₱ ${nomnomPointsUsed.toStringAsFixed(2)}"),
                          }
                        ],
                      )
                      // ...widget.data.cart.items.map(
                      //   (itm) => Row(
                      //     children: [Text("${itm.quantity}x ${itm.menuName}")],
                      //   ),
                      // )
                    ],
                  ),
                ),
              ],
            ),
          )),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                            text: "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: " ( incl. VAT )",
                                style: TextStyle(
                                  color: grey,
                                  fontSize: 12,
                                ),
                              )
                            ]),
                      ),
                      Text(
                        "₱ ${(widget.data.pricing.total - nomnomPointsUsed).ceil().toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: "",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  MaterialButton(
                    height: 50,
                    color: orangePalette,
                    elevation: 0,
                    onPressed: () async {
                      if (_kForm.currentState!.validate()) {
                        ref
                            .read(cartLoadingProvider.notifier)
                            .update((r) => true);

                        final List<RiderFirestore> f =
                            await _firestore.getRidersFromFirestore();
                        print(f);
                        if (f.isNotEmpty) {
                          if (deliveryAddress == null) {
                            Fluttertoast.showToast(
                                msg: "Please select an address");
                            return;
                          }
                          final List<RiderOpinion> top3 = await f.getTop3(
                              storePoint:
                                  widget.data.cart.merchant.coordinates);
                          print("TOP 3 : ${top3.map((e) => e.distance)}");
                          final UserAddress newAddress =
                              deliveryAddress!.copyWith(
                            barangay: _brgy.text,
                            street: _street.text,
                          );
                          final order = await _api.checkout(
                            merchantId: widget.data.cart.merchant.id,
                            cartIds: widget.data.cart.items
                                .map((e) => e.cartID)
                                .toList(),
                            isPickup: delType.id == 2,
                            isPreorder: isPreorder,
                            deliveryDate: deliveryDate,
                            deliveryTime: deliveryTime
                                .addMinutes(widget.data.etaMinute + 10),
                            hasUtensils: false,
                            pricing: widget.data.pricing,
                            points: nomnomPointsUsed.toDouble(),
                            riderPredictions: top3,
                            isForFriend: widget.data.isForFriend,
                            storeLocation:
                                widget.data.cart.merchant.coordinates,
                            deliveryPoint: newAddress.coordinates,
                            address: newAddress,
                            landmark: _landmark.text,
                            note: widget.data.note,
                            name: _name.text,
                            lastname: _lastname.text,
                            isFriendPay: isFriendPay,
                            middlename: "",
                            mobileNumber: _phone.text,
                          );
                          if (order != null) {
                            await _firestore.addNewOrder(
                                order.order,
                                widget.data.etaMinute,
                                isFriendPay,
                                currentUser!.id,
                                merchant: widget.data.cart.merchant,
                                items: widget.data.cart.items
                                    .map((e) => "${e.quantity}x ${e.menuName}")
                                    .toList()
                                    .join(','),
                                riderIds: top3.map((e) => e.riderId).toList());
                          }
                          ref.invalidate(futureCartProvider);
                          ref.invalidate(futureClientPointsProvider);
                        }
                        // ref
                        //     .read(selectedLocationProvider.notifier)
                        //     .update((r) => initLocation);
                        // final List<RiderOpinion> riders = f;

                        // await Future.delayed(1000.ms);
                        ref
                            .read(cartLoadingProvider.notifier)
                            .update((r) => false);
                        if (f.isNotEmpty) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        }
                      } else {
                        Fluttertoast.showToast(msg: "Some fields are missing");
                      }
                    },
                    child: Center(
                        child: Text(
                      "Place Order",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
