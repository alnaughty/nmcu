import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_details.dart';

// ignore: must_be_immutable
class StoreCard extends StatelessWidget with ColorPalette {
  StoreCard({super.key, required this.store});
  final Merchant store;
  @override
  Widget build(BuildContext context) {
    print(store.photoUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoreDetailsPage(model: store),
            ),
          );
        },
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Hero(
                  tag: store.id,
                  child: CachedNetworkImage(
                    imageUrl: store.featuredPhoto ??
                        "https://customer.nomnomdelivery.com/images/no_image_placeholder.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Hero(
                        tag: store.photoUrl,
                        child: CachedNetworkImage(
                          imageUrl: store.photoUrl,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name.capitalizeWords(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < store.rating.averageRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: orangePalette,
                                size: 18,
                              ),
                            ),
                            const Gap(5),
                            Text(
                              "(${store.rating.count} reviews)",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(.5)),
                            )
                          ]),
                          const Gap(5),
                          Text(
                            store.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(.5)),
                          )
                        ],
                      ),
                    )
                    // Container(width: 60,height: 60,)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
