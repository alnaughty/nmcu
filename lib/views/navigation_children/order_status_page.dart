import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/date_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/dashed_divider.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/views/navigation_children/track_order_page.dart';

class OrderStatusPage extends ConsumerStatefulWidget {
  const OrderStatusPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OrderStatusPageState();
}

class _OrderStatusPageState extends ConsumerState<OrderStatusPage>
    with ColorPalette {
  static final FirebaseFirestoreSupport _firebase = FirebaseFirestoreSupport();
  late final StreamSubscription _deliveryStreamSubscription;
  late final Stream<List<DeliveryModel>> _deliveryStream;
  final DateFormat format = DateFormat('dd MMM, EEEE');
  initStream() {
    final UserModel? curentUser = ref.watch(currentUserProvider);
    if (curentUser == null) return;
    _deliveryStream =
        _firebase.listenToDeliveries(value: curentUser.id, key: "user_id");
    _deliveryStreamSubscription = _deliveryStream.listen((r) {
      final data = ref.read(activeOrdersProvider.notifier).update((x) => r
          .where(
              (e) => e.deliveryDate.isSameDay(DateTime.now()) && e.status < 5)
          .toList());
      print(data);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initStream();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _deliveryStreamSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final realtimeActiveOrders = ref.watch(activeOrdersProvider);
    return Scaffold(
      backgroundColor: subScaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Active Orders",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: realtimeActiveOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/rider.png",
                    height: 150,
                  ),
                  const Gap(15),
                  Text(
                    "No active orders for today",
                  )
                ],
              ),
            )
          : SafeArea(
              top: false,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                itemBuilder: (_, i) {
                  final DeliveryModel model = realtimeActiveOrders[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackOrderPage(
                            id: model.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                model.reference,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: darkGrey,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: orangePalette.withOpacity(1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                child: Text(
                                  model.statusString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Text(
                            model.itemsString,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: grey,
                            ),
                          ),
                          DashedDivider(
                            dashHeight: 1,
                            color: textField,
                          ),
                          Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: model.merchant.photoUrl,
                                height: 45,
                                width: 45,
                                fit: BoxFit.cover,
                              ),
                              const Gap(10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model.merchant.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      format.format(model.deliveryDate),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: grey,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                              const Gap(10),
                              Text(
                                "₱ ${model.total.ceil().toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontFamily: "",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, i) => const Gap(15),
                itemCount: realtimeActiveOrders.length,
              ),
            ),
    );
  }
}
