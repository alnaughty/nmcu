import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/geo_point_ext.dart';
import 'package:nomnom/app/extensions/list_ext.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/extensions/time_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/apple_pay_button.dart';
import 'package:nomnom/app/widgets/dashed_divider.dart';
import 'package:nomnom/app/widgets/google_pay_button.dart';
import 'package:nomnom/app/widgets/payment_options_change.dart';
import 'package:nomnom/models/cart/cart_item.dart';
import 'package:nomnom/models/user/rider_firestore.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/cart_api.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/cart_menu_listing.dart';
import 'package:nomnom/views/navigation_children/show_addresses.dart';
import 'package:pay/pay.dart';

class PlaceOrderPage extends ConsumerStatefulWidget {
  const PlaceOrderPage({super.key, required this.data});
  final CheckoutData data;
  @override
  ConsumerState<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends ConsumerState<PlaceOrderPage>
    with ColorPalette {
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mddleName = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final CartApi _api = CartApi();
  late DeliveryType delType = widget.data.deliveryType;
  late DateTime deliveryDate = widget.data.deliveryDate;
  late TimeOfDay deliveryTime = widget.data.deliveryTime;
  late bool isPreorder = widget.data.isPreorder;
  int paymentMethod = 0;
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  double calculateDeliveryFee({
    required GeoPoint store,
  }) {
    final double totalDistance = calculateTotalDistance(store: store);
    print("TOTAL DISTANCE : $totalDistance");
    final settings = ref.read(areaSettingsProvider);
    if (settings != null) {
      print("ASDASD");
      double ratePerKm = 0;
      if (totalDistance < settings.setting.applicableDistance) {
        print("<");
        ratePerKm = settings.setting.deliveryRatePerKm;
      } else {
        print(">");
        ratePerKm = settings.setting.deliveryRatePerKmBeyond;
      }
      final double dst = calculateTotalDistance(store: store);
      print("RESULT $ratePerKm * $dst: ${dst * ratePerKm}");
      return (ratePerKm * dst).ceilToDouble();
    }
    // print(calculateTotalDistance(stores: stores));
    return 0.0;
  }

  double calculateTotalDistance({required GeoPoint store}) {
    final deliveryAddress = ref.watch(selectedLocationProvider);
    if (deliveryAddress == null) {
      Fluttertoast.showToast(msg: "Enable Location");
      return 0.0;
    }
    double totalDistance = 0.0;
    double distance = store.calculateDistance(deliveryAddress.coordinates);
    totalDistance += distance;
    double averageDistance = totalDistance;
    return averageDistance;
  }

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

  bool hasUtensils = false;
  final FirebaseFirestoreSupport _firebase = FirebaseFirestoreSupport();
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
  bool editablePhone = true;
  bool editableName = true;
  bool editableLastname = true;
  bool editableMiddlename = true;
  double nomnomPointsUsed = 0.0;
  initContactInfo() {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return;
    _name.text = currentUser.firstname;
    _mddleName.text = currentUser.middlename ?? "";
    _lastname.text = currentUser.lastname;
    _phone.text = currentUser.phoneNumber ?? "";
    editablePhone = _phone.text.isEmpty;
    editableLastname = _lastname.text.isEmpty;
    editableName = _name.text.isEmpty;
    editableMiddlename = _mddleName.text.isEmpty;
    setState(() {});
  }

  Future<void> payOnline() async {
    try {
      final PaymentItem item = PaymentItem(
        status: PaymentItemStatus.final_price,
        amount:
            "${(widget.data.pricing.total - nomnomPointsUsed).ceilToDouble()}",
      );
      final PayProvider provider =
          Platform.isIOS ? PayProvider.apple_pay : PayProvider.google_pay;
      final jsonString = Platform.isIOS ? "apay.json" : "gpay.json";
      print("$jsonString");
      final jsonConfig = await rootBundle.loadString(jsonString);
      print(jsonConfig);
      final Pay pay =
          Pay({provider: PaymentConfiguration.fromJsonString(jsonConfig)});
      final bool canPay = await pay.userCanPay(provider);
      print("Can Pay: $canPay");
      // return;
      if (canPay) {
        await pay.showPaymentSelector(
          provider,
          [item],
        ).then((v) {
          print(v.toString());
        });
      } else {
        Fluttertoast.showToast(msg: "Make sure your device is logged in");
      }
    } catch (e, s) {
      print("ERROR :$e");
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initContactInfo();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    final initLocation = selectedLocation;
    final double points = ref.watch(clientPointProvider);
    final currentUser = ref.watch(currentUserProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ImageIcon(
                                  AssetImage(delType.id == 1
                                      ? "assets/icons/location.png"
                                      : "assets/icons/bag_filled.png"),
                                  color: orangePalette,
                                ),
                                const Gap(10),
                                Text(
                                  delType.id == 1
                                      ? "Delivery address"
                                      : "Pick Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                            if (selectedLocation != null) ...{
                              InkWell(
                                onTap: () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => ShowAddresses(
                                      onSelect: (UserAddress address) {
                                        widget.data.etaMinute =
                                            calculateAverageETA(
                                                deliveryAddress: address,
                                                store: widget.data.cart.merchant
                                                    .coordinates);
                                      },
                                    ),
                                  );
                                  // selectedLocation.id ==
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      ImageIcon(
                                        AssetImage("assets/icons/pen.png"),
                                        color: grey,
                                        size: 15,
                                      ),
                                      const Gap(10),
                                      Text(
                                        "Update",
                                        style: TextStyle(
                                            fontSize: 12, color: grey),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            },
                          ],
                        ),
                        if (selectedLocation != null) ...{
                          const Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLocation.title.capitalize(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                selectedLocation.addressLine,
                              )
                            ],
                          ),
                        },
                        if (delType.id == 1) ...{
                          DashedDivider(
                            dashHeight: 1.5,
                            color: textField,
                          ),
                          TextField(
                            controller: _landmark,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                            decoration: InputDecoration(
                              label: Text(
                                "Landmark (optional)",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              hintText: "Places near you",
                            ),
                          )
                        },
                      ],
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
                        titler(
                          label: "Contact Info",
                          icon: Icon(
                            Icons.person,
                            color: orangePalette,
                          ),
                        ),
                        const Gap(15),
                        Form(
                          key: _kForm,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      enabled: editableName,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return "This field is required";
                                        }
                                        return null;
                                      },
                                      controller: _name,
                                      decoration: const InputDecoration(
                                        labelText: "First name",
                                        hintText: "First name",
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      // validator: (text) {
                                      //   if (text == null || text.isEmpty) {
                                      //     return "This field is required";
                                      //   }
                                      //   return null;
                                      // },
                                      controller: _mddleName,
                                      decoration: const InputDecoration(
                                        labelText: "Middle name (optional)",
                                        hintText: "Middle name",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              TextFormField(
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                enabled: editableLastname,
                                controller: _lastname,
                                decoration: const InputDecoration(
                                  labelText: "Lastname",
                                  hintText: "Lastname",
                                ),
                              ),
                              const Gap(10),
                              TextFormField(
                                enabled: editablePhone,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                keyboardType: TextInputType.numberWithOptions(),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  } else if (!text.isValidPhoneNumber()) {
                                    return "Must be a valid phone number";
                                  }
                                  return null;
                                },
                                controller: _phone,
                                decoration: const InputDecoration(
                                    labelText: "Contact Number",
                                    hintText: "9XXXXXXX",
                                    prefix: Text("+63")),
                              ),
                            ],
                          ),
                        )
                      ],
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            InkWell(
                              onTap: () async {
                                await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => PaymentOptionsChange(
                                        initialOption: paymentMethod,
                                        newOptionCallback: (int m) {
                                          setState(() {
                                            paymentMethod = m;
                                          });
                                        }));
                              },
                              child: Text(
                                "Change",
                                style: TextStyle(
                                  color: orangePalette,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
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
                        )
                      ],
                    ),
                  ),
                  const Gap(15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (nomnomPointsUsed == 0) {
                                if (points < 5) {
                                  Fluttertoast.showToast(
                                      msg: "Cannot use points yet");
                                  return;
                                }
                                nomnomPointsUsed = points;
                              } else {
                                nomnomPointsUsed = 0.0;
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: nomnomPointsUsed == 0
                                  ? textField
                                  : orangePalette,
                            ),
                            child: Text(
                              "${points.toStringAsFixed(2)}pts",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Gap(15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Use nomnom coins?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Should atleast have 5 points to use this feature",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
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
                  const Gap(15),
                  // Container(

                  // ),
                  const Gap(20),
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 250,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "By completing this order, I agree to all",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          InkWell(
                            onTap: () {},
                            child: Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: orangePalette,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
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
                          fontFamily: "",
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  if (paymentMethod == 0) ...{
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
                              await _firebase.getRidersFromFirestore();

                          if (f.isNotEmpty) {
                            final List<RiderOpinion> top3 = await f.getTop3(
                                storePoint:
                                    widget.data.cart.merchant.coordinates);
                            print("TOP 3 : ${top3.map((e) => e.distance)}");
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
                              hasUtensils: hasUtensils,
                              pricing: widget.data.pricing,
                              points: nomnomPointsUsed,
                              riderPredictions: top3,
                              isForFriend: widget.data.isForFriend,
                              storeLocation:
                                  widget.data.cart.merchant.coordinates,
                              deliveryPoint: selectedLocation!.coordinates,
                              address: selectedLocation,
                              landmark: _landmark.text,
                              note: widget.data.note,
                              name: _name.text,
                              lastname: _lastname.text,
                              isFriendPay: false,
                              middlename: _mddleName.text,
                              mobileNumber: _phone.text,
                            );
                            if (order != null) {
                              Fluttertoast.showToast(
                                  msg: "${order.reference} has been placed");
                              await _firestore.addNewOrder(order.order,
                                  widget.data.etaMinute, false, currentUser!.id,
                                  merchant: widget.data.cart.merchant,
                                  items: widget.data.cart.items
                                      .map(
                                          (e) => "${e.quantity}x ${e.menuName}")
                                      .toList()
                                      .join(','),
                                  riderIds:
                                      top3.map((e) => e.riderId).toList());
                            }
                            ref.invalidate(futureCartProvider);
                            ref.invalidate(futureClientPointsProvider);
                          }
                          ref
                              .read(selectedLocationProvider.notifier)
                              .update((r) => initLocation);
                          // final List<RiderOpinion> riders = f;

                          // await Future.delayed(1000.ms);
                          ref
                              .read(cartLoadingProvider.notifier)
                              .update((r) => false);
                          if (f.isNotEmpty) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }
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
                    ),
                  } else ...{
                    if (Platform.isIOS) ...{
                      CustomApplePayButton(
                          items: [
                            ...widget.data.cart.items.map(
                              (e) => PaymentItem(
                                status: PaymentItemStatus.final_price,
                                type: PaymentItemType.item,
                                label: e.menuName,
                                amount: e.subtotal.toStringAsFixed(2),
                              ),
                            ),
                            PaymentItem(
                              label: "Delivery Fee",
                              type: PaymentItemType.item,
                              status: PaymentItemStatus.final_price,
                              amount: widget.data.pricing.deliveryFee
                                  .toStringAsFixed(2),
                            ),
                            PaymentItem(
                              label: "Nom Nom Delivery App",
                              type: PaymentItemType.total,
                              status: PaymentItemStatus.final_price,
                              amount:
                                  (widget.data.pricing.total - nomnomPointsUsed)
                                      .ceil()
                                      .toStringAsFixed(2),
                            ),
                          ],
                          onResult: (paymentResult) {
                            print(paymentResult.toString());
                          },
                          merchantName: "",
                          total: (widget.data.pricing.total - nomnomPointsUsed)
                              .ceilToDouble())
                    } else ...{
                      CustomGooglePayButton(
                        onResult: (paymentResult) {
                          print(paymentResult.toString());
                        },
                        merchantName: '',
                        total: (widget.data.pricing.total - nomnomPointsUsed)
                            .ceilToDouble(),
                      )
                    }
                  },
                  // if (Platform.isIOS) ...{
                  //   CustomApplePayButton(
                  //     merchantName: widget.data.cart.merchant.name,
                  // total: (widget.data.pricing.total - nomnomPointsUsed)
                  //     .ceilToDouble(),
                  //   )
                  // } else ...{
                  //   CustomGooglePayButton(
                  //       merchantName: widget.data.cart.merchant.name,
                  //       total: (widget.data.pricing.total - nomnomPointsUsed)),
                  // },
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
