import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/orders/order_model.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/views/navigation_children/drawer_children/order_card.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> with ColorPalette {
  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  late Stream<List<DeliveryModel>> orderStream;
  late StreamSubscription<List<DeliveryModel>> orderStreamSubscription;
  initStream() {
    final cu = ref.watch(currentUserProvider);
    if (cu == null) return;
    orderStream = _firestore.listenToDeliveries(value: cu.id, key: "user_id");
    orderStreamSubscription = orderStream.listen((r) {
      final List<DeliveryModel> actives = r.where((e) => e.status < 5).toList();
      final List<DeliveryModel> history =
          r.where((e) => e.status >= 5).toList();
      history.sort((a, b) {
        return b.deliveryDate.compareTo(a.deliveryDate);
      });
      actives.sort((a, b) {
        return b.deliveryDate.compareTo(a.deliveryDate);
      });
      ref.read(activeOrdersProvider.notifier).update((s) => actives);
      ref.read(pastOrdersProvider.notifier).update((s) => history);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initStream();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    orderStreamSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final activeOrders = ref.watch(activeOrdersProvider);
    final historyOrders = ref.watch(pastOrdersProvider);
    return Scaffold(
      backgroundColor: subScaffoldColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        iconTheme: IconThemeData(color: Colors.white),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                        title: Text(
                          "My Orders",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Orders",
                    style: titleStyle,
                  ),
                  if (activeOrders == null) ...{
                    SizedBox(
                      height: size.height * .5,
                      width: size.width,
                      child: Center(
                        child: CustomLoader(
                          color: darkGrey,
                        ),
                      ),
                    ),
                  } else if (activeOrders.isEmpty) ...{
                    SizedBox(
                      height: size.height * .25,
                      width: size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/open-box.png",
                            height: 110,
                          ),
                          const Gap(10),
                          Text(
                            "You have no active orders for today",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: grey,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Order now",
                              style: TextStyle(color: orangePalette),
                            ),
                          )
                        ],
                      ),
                    ),
                  } else ...{
                    const Gap(20),
                    ListView.separated(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final DeliveryModel order = activeOrders[i];
                          return OrderCard(order: order);
                        },
                        separatorBuilder: (_, i) => const Gap(10),
                        itemCount: activeOrders.length)
                  },
                  const Gap(20),
                  Text(
                    "Past Orders ",
                    style: titleStyle,
                  ),
                  if (historyOrders == null) ...{
                    SizedBox(
                      height: size.height * .5,
                      width: size.width,
                      child: Center(
                        child: CustomLoader(
                          color: darkGrey,
                        ),
                      ),
                    ),
                  } else if (historyOrders.isEmpty) ...{
                    SizedBox(
                      height: size.height * .25,
                      width: size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/open-box.png",
                            height: 110,
                          ),
                          const Gap(10),
                          Text(
                            "You have no past orders",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: grey,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Order now",
                              style: TextStyle(color: orangePalette),
                            ),
                          )
                        ],
                      ),
                    ),
                  } else ...{
                    const Gap(20),
                    ListView.separated(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        final DeliveryModel order = historyOrders[i];
                        return OrderCard(order: order);
                      },
                      separatorBuilder: (_, i) => const Gap(10),
                      itemCount: historyOrders.length,
                    )
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
