import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/routes.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_details.dart';

class VisitShop extends StatefulWidget {
  const VisitShop({super.key, required this.store});
  final Merchant store;
  @override
  State<VisitShop> createState() => _VisitShopState();
}

class _VisitShopState extends State<VisitShop> with ColorPalette {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: widget.store.photoUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.store.name.capitalizeWords(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.store.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, color: Colors.black.withOpacity(.5)),
                )
              ],
            ),
          ),
          const Gap(10),

          // TextButton.icon(
          //   style: ButtonStyle(
          //     maximumSize: WidgetStatePropertyAll(Size.fromHeight(40))
          //     shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(6))),
          //     foregroundColor: WidgetStatePropertyAll(Colors.white),
          //     padding: WidgetStatePropertyAll(
          //         const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
          //     backgroundColor: WidgetStatePropertyAll(orangePalette),
          //   ),
          //   onPressed: () {},
          //   label: Text(
          //     "Visit",
          //     style: TextStyle(
          //       fontSize: 12,
          //     ),
          //   ),
          // )
          SizedBox(
            width: 75,
            child: MaterialButton(
              elevation: 0,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StoreDetailsPage(model: widget.store),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: orangePalette,
              height: 35,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store,
                      size: 15,
                      color: Colors.white,
                    ),
                    const Gap(5),
                    Text(
                      "Visit",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          )
          // Container(
          // width: 50,
          // height: 50,
          //   color: Colors.red,
          // )
        ],
      ),
    );
  }
}
