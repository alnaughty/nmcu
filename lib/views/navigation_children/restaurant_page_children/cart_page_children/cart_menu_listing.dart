import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/geo_point_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/custom_radio_button.dart';
import 'package:nomnom/models/cart/cart_item.dart';
import 'package:nomnom/models/cart/cart_model.dart';
import 'package:nomnom/models/merchant/promo.dart';
import 'package:nomnom/models/tuple.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/change_type_modal.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/merchant_promo_codes.dart';

class CheckoutData {
  final CartModel cart;
  final DeliveryPricing pricing;
  final DeliveryType deliveryType;
  final bool isForFriend;
  final bool isPreorder;
  final DateTime deliveryDate;
  final TimeOfDay deliveryTime;
  final String note;
  int etaMinute;
  CheckoutData(
      {required this.cart,
      required this.deliveryDate,
      required this.deliveryTime,
      required this.deliveryType,
      required this.isForFriend,
      required this.isPreorder,
      required this.note,
      required this.etaMinute,
      required this.pricing});
}

class CartMenuListing extends ConsumerStatefulWidget {
  const CartMenuListing({super.key, required this.onCheckout});
  // final ValueChanged<List<CartModel>> selectedCart;
  final ValueChanged<CheckoutData> onCheckout;
  @override
  ConsumerState<CartMenuListing> createState() => _CartMenuListingState();
}

class DeliveryPricing {
  final double deliveryFee, subtotal;
  double total, promoDeduction;
  String promoCode;

  DeliveryPricing({
    required this.deliveryFee,
    required this.promoDeduction,
    required this.subtotal,
    required this.total,
    required this.promoCode,
  });

  Map<String, dynamic> toJson() => {
        "delivery_fee": deliveryFee,
        "sub_total": subtotal,
        "total": total,
        "promo_deduction": promoDeduction,
        "promo_code": promoCode,
      };

  @override
  String toString() => "${toJson()}";
}

class DeliveryType {
  final int id;
  final String title, photoPath;
  const DeliveryType(
      {required this.id, required this.photoPath, required this.title});
}

class _CartMenuListingState extends ConsumerState<CartMenuListing>
    with ColorPalette {
  CartModel? selectedCartModel;
  DeliveryPricing? selectedPricing;
  late DeliveryType selectedDeliveryType = deliveryType.first;
  final List<DeliveryType> deliveryType = [
    DeliveryType(
      id: 1,
      photoPath: "assets/images/food_delivery.png",
      title: "Food Delivery",
    ),
    DeliveryType(
      id: 2,
      photoPath: "assets/images/food_pick-up.png",
      title: "Food Pick-up",
    ),
  ];
  final DateFormat format = DateFormat('MMM. dd');
  DateTime deliveryDate = DateTime.now();
  TimeOfDay deliveryTime = TimeOfDay.now();

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
    required GeoPoint store,
    double speed = 30,
  }) {
    // if (stores.isEmpty) {
    //   throw ArgumentError("At least one store is required.");
    // }
    final deliveryAddress = ref.watch(selectedLocationProvider);
    if (deliveryAddress == null) {
      Fluttertoast.showToast(msg: "Enable Location");
      throw "";
    }
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

  late String selectedItemUnavailability = unavialbleList.first;
  final List<String> unavialbleList = [
    "Remove it from my order",
    "Change to similar item",
    "Cancel transaction",
  ];
  bool isPreorder = false;

  double calculateTotalSubtotal(CartModel cartModel) {
    final double merchantTotal = cartModel.items
        .fold(0, (subtotal, cartItem) => subtotal + cartItem.subtotal);
    return merchantTotal;
    // return
    // return cartModels.fold(0.0, (total, cartModel) {
    //   double merchantTotal = cartModel.items
    //       .fold(0.0, (subtotal, cartItem) => subtotal + cartItem.subtotal);
    //   return total + merchantTotal;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(futureCartProvider);
    return result.when(
        data: (data) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // selected Delivery Type
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Row(
                          children: [
                            Image.asset(
                              selectedDeliveryType.photoPath,
                              height: 100,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "nom nom",
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    selectedDeliveryType.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: orangePalette,
                                                size: 20,
                                              ),
                                              const Gap(10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (selectedCartModel !=
                                                        null) ...{
                                                      Text(
                                                        isPreorder ||
                                                                selectedDeliveryType
                                                                        .id ==
                                                                    2
                                                            ? selectedDeliveryType
                                                                        .id ==
                                                                    2
                                                                ? "Pick-up"
                                                                : "Pre-order"
                                                            : "ASAP (${calculateAverageETA(store: selectedCartModel!.merchant.coordinates)}min)",
                                                        // ",",
                                                        style: TextStyle(
                                                          color: orangePalette,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    } else ...{
                                                      Text(
                                                        "Please select a store",
                                                        // ",",
                                                        style: TextStyle(
                                                          color: orangePalette,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    },
                                                    if (isPreorder ||
                                                        selectedDeliveryType
                                                                .id ==
                                                            2) ...{
                                                      Text.rich(
                                                        TextSpan(
                                                            text: format
                                                                .format(
                                                                    deliveryDate)
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                  text:
                                                                      " (${deliveryTime.format(context)})",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            .5),
                                                                  ))
                                                            ]),
                                                      )
                                                      // Text(
                                                      // format
                                                      //     .format(deliveryDate)
                                                      //     .toUpperCase(),
                                                      // style: TextStyle(
                                                      //   fontSize: 12,
                                                      //   fontWeight: FontWeight.w600,
                                                      // ),
                                                      // )
                                                    } else ...{
                                                      Text(
                                                        "Estimated delivery",
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      )
                                                    },
                                                    // Text("data")
                                                  ],
                                                ),
                                              ),
                                              const Gap(10),
                                              SizedBox(
                                                width: 57,
                                                child: MaterialButton(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  elevation: 0,
                                                  color:
                                                      const Color(0xFFF1f1f1),
                                                  onPressed: () async {
                                                    await showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (context) =>
                                                          ChangeTypeModal(
                                                        initDate: deliveryDate,
                                                        initTime: deliveryTime,
                                                        initDeliveryType:
                                                            selectedDeliveryType,
                                                        onTypeChanged: (d) {
                                                          setState(() {
                                                            selectedDeliveryType =
                                                                d;
                                                          });
                                                        },
                                                        onDateChanged: (d) {
                                                          isPreorder =
                                                              d.isAfter(DateTime
                                                                  .now());
                                                          // print(deliveryDate)
                                                          setState(() {
                                                            deliveryDate = d;
                                                          });
                                                        },
                                                        onTimeChanged: (t) {
                                                          setState(() {
                                                            deliveryTime = t;
                                                          });
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      "Change",
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ))
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const Gap(20),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(vertical: 10),
                      //   child: Center(
                      //     child: SizedBox(
                      //         width: 218,
                      //         child: Text(
                      //           "You can order from up to 2 restaurants.",
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.w500,
                      //             color: grey,
                      //           ),
                      //         )),
                      //   ),
                      // ),
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final CartModel model = data[i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomRadioButton(
                                currentState: selectedCartModel == model,
                                callback: (bool f) {
                                  selectedCartModel = model;
                                  final double subtotal =
                                      calculateTotalSubtotal(model);
                                  // final double total = cal
                                  final double deliveryFee =
                                      calculateDeliveryFee(
                                          store: model.merchant.coordinates);
                                  final f = DeliveryPricing(
                                    promoCode: "",
                                    deliveryFee: deliveryFee,
                                    promoDeduction: 0,
                                    subtotal: subtotal,
                                    total: subtotal + deliveryFee,
                                  );
                                  selectedPricing = f;
                                  setState(() {});
                                },
                                label: model.merchant.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              // Text(
                              //   model.merchant.name,

                              // ),
                              const Gap(10),
                              ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (_, index) {
                                    final CartItem item = model.items[index];
                                    return Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                              shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    side: BorderSide(
                                                        color: textField)),
                                              ),
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.black),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                Colors.transparent,
                                              )),
                                          child: Row(
                                            children: [
                                              Text(
                                                item.quantity.toString(),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  height: 1,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Gap(5),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                              )
                                            ],
                                          ),
                                        ),
                                        const Gap(10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.menuName,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                item.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: grey,
                                                ),
                                              ),
                                              Text(
                                                "₱ ${item.subtotal.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontFamily: "",
                                                  color: grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const Gap(10),
                                        CachedNetworkImage(
                                          imageUrl: item.photoUrl,
                                          height: 50,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        )
                                      ],
                                    );
                                  },
                                  separatorBuilder: (_, i) => const Gap(10),
                                  itemCount: model.items.length),
                            ],
                          );
                        },
                        separatorBuilder: (_, i) => const Gap(10),
                        itemCount: data.length,
                      ),
                      // const Gap(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {},
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "Add more items",
                                  style: TextStyle(
                                    color: orangePalette,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "If item is not available",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: textField)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      borderRadius: BorderRadius.circular(6),
                                      isExpanded: true,
                                      icon: Icon(
                                          Icons.keyboard_arrow_down_outlined),
                                      value: selectedItemUnavailability,
                                      items: unavialbleList
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (s) {
                                        setState(() {
                                          selectedItemUnavailability =
                                              s ?? unavialbleList.first;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            if (selectedCartModel != null ||
                                selectedPricing != null) ...{
                              const Gap(10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Subtotal",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "₱ ${selectedPricing!.subtotal}",
                                    style: TextStyle(
                                      fontFamily: "",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // const Gap(5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Delivery fee",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: grey,
                                    ),
                                  ),
                                  Text(
                                    "₱ ${selectedPricing!.deliveryFee.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "",
                                      fontWeight: FontWeight.w500,
                                      color: grey,
                                    ),
                                  ),
                                ],
                              ),
                            },
                            const Gap(10),
                            if (selectedCartModel != null &&
                                selectedPricing != null) ...{
                              MaterialButton(
                                height: 50,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: orangePalette,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(6)),
                                onPressed: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MerchantPromoCodes(
                                          merchantID:
                                              selectedCartModel!.merchant.id,
                                          onPromoSelected: (PromoModel promo) {
                                            if (selectedPricing!.subtotal >=
                                                promo.minimumOrderAmount) {
                                              print(selectedPricing);
                                              print(selectedPricing);
                                              String code = "";
                                              double promoDeduction = 0.0;
                                              double total = selectedPricing!
                                                      .subtotal +
                                                  selectedPricing!.deliveryFee;
                                              selectedPricing!.promoDeduction =
                                                  promoDeduction;
                                              selectedPricing!.total = total;
                                              print(selectedPricing);
                                              print(selectedPricing);
                                              if (promo.promoType == 1) {
                                                //deduct delivery fee
                                                total -= selectedPricing!
                                                    .deliveryFee;
                                                double tempDF = selectedPricing!
                                                    .deliveryFee;
                                                if (promo.valueType == 1) {
                                                  tempDF -= promo.value;
                                                  promoDeduction = promo.value;
                                                } else {
                                                  promoDeduction = (tempDF *
                                                      (promo.value / 100));
                                                  tempDF =
                                                      tempDF - promoDeduction;
                                                }
                                                total += tempDF;
                                              } else if (promo.promoType == 2) {
                                                // deduct subtotal
                                                total -=
                                                    selectedPricing!.subtotal;
                                                double tempSubtotal =
                                                    selectedPricing!.subtotal;
                                                if (promo.valueType == 1) {
                                                  tempSubtotal -= promo.value;
                                                  promoDeduction = promo.value;
                                                } else {
                                                  promoDeduction =
                                                      (tempSubtotal *
                                                          (promo.value / 100));
                                                  tempSubtotal = tempSubtotal -
                                                      promoDeduction;
                                                }
                                                total += tempSubtotal;
                                              } else {
                                                double tempTotal = total;
                                                // deduct total
                                                if (promo.valueType == 1) {
                                                  tempTotal -= promo.value;
                                                  promoDeduction = promo.value;
                                                } else {
                                                  promoDeduction = (tempTotal *
                                                      (promo.value / 100));
                                                  tempTotal = tempTotal -
                                                      promoDeduction;
                                                }
                                                total = tempTotal;
                                              }
                                              print(
                                                  "OLD TOTAL : ${selectedPricing!.total}");
                                              print("NEW TOTAL : $total");

                                              setState(() {
                                                selectedPricing!.promoCode =
                                                    promo.promoCode;
                                                selectedPricing!.total = total;
                                                selectedPricing!
                                                        .promoDeduction =
                                                    promoDeduction;
                                              });
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Minimum order not reached");
                                            }
                                          },
                                        ),
                                      ));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                      AssetImage(
                                        "assets/icons/promo.png",
                                      ),
                                      color: orangePalette,
                                    ),
                                    const Gap(10),
                                    Text(
                                      "Promo code",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: orangePalette),
                                    )
                                  ],
                                ),
                              ),
                            },
                          ],
                        ),
                      ),

                      const SafeArea(
                        child: SizedBox(),
                      )
                    ],
                  ),
                ),
              ),
              if (selectedPricing != null && selectedCartModel != null) ...{
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (selectedPricing!.promoDeduction > 0) ...{
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Discount",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "- ₱ ${selectedPricing!.promoDeduction.toInt().toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: grey,
                                    fontSize: 12,
                                    fontFamily: "",
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          const Gap(5),
                        },
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
                              "₱ ${selectedPricing!.total.ceil().toStringAsFixed(2)}",
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
                          height: 55,
                          color: orangePalette,
                          onPressed: () {
                            if (selectedCartModel != null &&
                                selectedPricing != null) {
                              widget.onCheckout(CheckoutData(
                                cart: selectedCartModel!,
                                deliveryDate: deliveryDate,
                                deliveryTime: deliveryTime,
                                deliveryType: selectedDeliveryType,
                                isForFriend: false,
                                isPreorder: isPreorder,
                                pricing: selectedPricing!,
                                note: selectedItemUnavailability,
                                etaMinute: selectedDeliveryType.id == 1
                                    ? calculateAverageETA(
                                        store: selectedCartModel!
                                            .merchant.coordinates)
                                    : 0,
                              ));
                            }
                          },
                          elevation: 0,
                          child: Center(
                            child: Text(
                              "Proceed to check-out",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        MaterialButton(
                          height: 55,
                          color: Colors.transparent,
                          onPressed: () {
                            if (selectedCartModel != null &&
                                selectedPricing != null) {
                              widget.onCheckout(CheckoutData(
                                cart: selectedCartModel!,
                                deliveryDate: deliveryDate,
                                isPreorder: isPreorder,
                                deliveryTime: deliveryTime,
                                deliveryType: selectedDeliveryType,
                                isForFriend: true,
                                pricing: selectedPricing!,
                                note: selectedItemUnavailability,
                                etaMinute: selectedDeliveryType.id == 1
                                    ? calculateAverageETA(
                                        store: selectedCartModel!
                                            .merchant.coordinates)
                                    : 0,
                              ));
                            }
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side:
                                  BorderSide(color: orangePalette, width: 1.5)),
                          elevation: 0,
                          child: Center(
                            child: Text(
                              "Order for a friend",
                              style: TextStyle(
                                color: orangePalette,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              }
            ],
          );
        },
        error: (error, s) => Container(),
        loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/rider.png",
                    height: 100,
                  ),
                  const Gap(10),
                  CustomLoader(
                    color: darkGrey,
                    label: "Fetching cart data",
                  )
                ],
              ),
            ));
    // final
    // return SingleChildScrollView(
    //   child: Column(
    //     children: [],
    //   ),
    // );
  }
}
