import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/orders/order_model.dart';
import 'package:nomnom/views/navigation_children/track_order_page.dart';

// ignore: must_be_immutable
class OrderCard extends StatelessWidget with ColorPalette {
  OrderCard({super.key, required this.order});
  final DeliveryModel order;
  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  final DateFormat formate = DateFormat("dd MMM, hh:mm a");
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackOrderPage(id: order.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.merchant.name.capitalizeWords(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        order.reference,
                        style: TextStyle(
                          color: grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                  Text(
                    order.itemsString,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: size.width * .2, maxHeight: 25),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: order.statusColor(),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              order.statusString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Gap(10),
                          Text(
                            formate.format(
                              order.deliveryDate,
                            ),
                            style: TextStyle(fontSize: 12, color: grey),
                          )
                        ],
                      ),
                      Text(
                        "P ${order.total}",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: order.merchant.photoUrl,
                height: 65,
                width: 65,
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }
}
