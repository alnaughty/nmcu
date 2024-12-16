import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/services/api/order_api.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';

class RateDeliveredOrderPage extends ConsumerStatefulWidget {
  const RateDeliveredOrderPage(
      {super.key, required this.model, required this.loadingProvider});
  final DeliveryModel model;
  final StateProvider<bool> loadingProvider;
  @override
  ConsumerState<RateDeliveredOrderPage> createState() =>
      _RateDeliveredOrderPageState();
}

class _RateDeliveredOrderPageState extends ConsumerState<RateDeliveredOrderPage>
    with ColorPalette {
  final OrderApi _api = OrderApi();
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  late final TextEditingController _riderReview = TextEditingController();
  late final TextEditingController _merchantReview = TextEditingController();
  int riderRate = 5;
  int merchantRate = 5;
  late final DeliveryModel model = widget.model;

  reviewFieldBuilder(
          {required TextEditingController controller,
          required bool isEnabled}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Review",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(5),
          TextField(
            controller: controller,
            enabled: isEnabled,
            minLines: 3,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
                hintText: "Write your review here",
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: grey,
                )),
          )
        ],
      );

  starBuilder(
          {required int currentIndex,
          required Function(int)? onIndexChanged}) =>
      Row(
        children: List.generate(
            5,
            (i) => InkWell(
                  onTap: onIndexChanged == null
                      ? null
                      : () {
                          setState(() {
                            if (currentIndex == i + 1) {
                              currentIndex = 0;
                            } else {
                              currentIndex = i + 1;
                            }
                          });
                          onIndexChanged(currentIndex);
                          print(i);
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      currentIndex >= i + 1 ? Icons.star : Icons.star_border,
                      color: orangePalette,
                      size: 20,
                    ),
                  ),
                )),
      );
  check() {
    _merchantReview.text = model.merchant.rate?.feedback ?? "";
    merchantRate = model.merchant.rate?.rate ?? 5;
    _riderReview.text = model.rider?.rate?.feedback ?? "";
    riderRate = model.rider?.rate?.rate ?? 5;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      check();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _merchantReview.dispose();

    _riderReview.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(30),
          Center(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/rider.png",
                  width: 180,
                ),
                const Gap(35),
                Text("Order ${model!.statusString()}",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: orangePalette)),
                Text(
                  "Your order has been successfully delivered! We hope you love your purchase and look forward to serving you again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          const Gap(30),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://back.nomnomdelivery.com${model!.rider!.photoUrl}",
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model!.rider!.fullname.capitalizeWords(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "nom nom rider",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: orangePalette),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const Gap(15),
                Text(
                  "Rate the driver assigned to your order",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(10),
                starBuilder(
                    currentIndex: riderRate,
                    onIndexChanged: model.rider?.rate != null
                        ? null
                        : (int i) {
                            print("ADSAS : $i");
                            setState(() {
                              riderRate = i;
                            });
                          }),
                const Gap(10),
                reviewFieldBuilder(
                  isEnabled: model.rider?.rate == null,
                  controller: _riderReview,
                )
              ],
            ),
          ),
          const Gap(20),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: model.merchant.photoUrl,
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.merchant.name.capitalizeWords(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "nom nom food delivery",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: orangePalette),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const Gap(15),
                Text(
                  "Rate the store that you ordered from",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(10),
                starBuilder(
                    currentIndex: merchantRate,
                    onIndexChanged: model.merchant.rate != null
                        ? null
                        : (int i) {
                            print("ADSAS : $i");
                            setState(() {
                              merchantRate = i;
                            });
                          }),
                const Gap(10),
                reviewFieldBuilder(
                  isEnabled: model.merchant.rate == null,
                  controller: _merchantReview,
                )
              ],
            ),
          ),
          const Gap(20),
          SafeArea(
            top: false,
            child: MaterialButton(
              elevation: 0,
              height: 50,
              color: orangePalette,
              onPressed: () async {
                ref.read(widget.loadingProvider.notifier).update((s) => true);
                if (model.merchant.rate == null) {
                  final hasStoreRated = await _api.reviewStore(
                      orderID: model.id,
                      rate: merchantRate,
                      feedback: _merchantReview.text);
                  if (hasStoreRated) {
                    await _firestore.review(
                        refcode: model.reference,
                        key: "merchant",
                        rate: FireRating(
                            feedback: _merchantReview.text,
                            rate: merchantRate));
                  }
                }
                if (model.rider?.rate == null) {
                  final hasRiderRated = await _api.reviewRider(
                      riderID: model.rider!.id,
                      orderID: model.id,
                      rate: merchantRate,
                      feedback: _merchantReview.text);
                  if (hasRiderRated) {
                    await _firestore.review(
                        refcode: model.reference,
                        key: "rider",
                        rate: FireRating(
                            feedback: _riderReview.text, rate: riderRate));
                  }
                }
                ref.read(widget.loadingProvider.notifier).update((s) => false);
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text("Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
