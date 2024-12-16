import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/views/navigation_children/order_status_page.dart';
import 'package:nomnom/views/navigation_children/track_order_page.dart';

class OrderStatusCard extends ConsumerStatefulWidget {
  const OrderStatusCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OrderStatusCardState();
}

class _OrderStatusCardState extends ConsumerState<OrderStatusCard>
    with ColorPalette {
  @override
  Widget build(BuildContext context) {
    final realtimeActiveOrders = ref.watch(activeOrdersProvider);
    if (realtimeActiveOrders.isEmpty) return Container();
    return Column(
      children: [
        if (realtimeActiveOrders.isNotEmpty) ...{
          GestureDetector(
            onTap: () {
              if (realtimeActiveOrders.length > 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderStatusPage(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackOrderPage(
                      id: realtimeActiveOrders.first.id,
                    ),
                  ),
                );
              }
            },
            child: SizedBox(
              height: 150,
              // color: Colors.red,
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: orangePalette, width: 2),
                        color: orangePalette.withOpacity(.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                realtimeActiveOrders.last.statusString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    height: 1),
                              ),
                              Text(
                                realtimeActiveOrders.length > 1
                                    ? "You have ${realtimeActiveOrders.length - 1} more order"
                                    : "This is your only order for today",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "Prepare ₱ ${realtimeActiveOrders.fold(0.0, (subtotal, cartItem) => subtotal + cartItem.total).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontFamily: "",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: -10,
                    bottom: 0,
                    child: Image.asset(
                      realtimeActiveOrders.last.status == 0
                          ? "assets/images/waiting.gif"
                          : realtimeActiveOrders.last.status == 1 ||
                                  realtimeActiveOrders.last.status == 11
                              ? "assets/images/preparing.gif"
                              : realtimeActiveOrders.last.status == 2 ||
                                      realtimeActiveOrders.last.status == 11
                                  ? "assets/images/ready.gif"
                                  : realtimeActiveOrders.last.status == 4 ||
                                          realtimeActiveOrders.last.status == 11
                                      ? "assets/images/arrive.gif"
                                      : "assets/images/rider.gif",
                    ),
                  )
                ],
              ),
            ),
          ),
          const Gap(15)
        },
      ],
    );
  }
}
