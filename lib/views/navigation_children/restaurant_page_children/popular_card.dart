import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/models/merchant/menu_item.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/menu_details.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_details.dart';

class PopularCard extends StatelessWidget {
  const PopularCard({super.key, required this.item, required this.width});
  final MenuItem item;
  final double width;
  static final Color red = const Color(0xFFFF0000);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.isAvailable
          ? () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MenuDetails(item: item)));
            }
          : null,
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.photoUrl,
                    width: width,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                  // Container(
                  // width: width,
                  // height: 160,
                  //   color: Colors.red,
                  // ),
                  const Spacer(),
                  SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.capitalizeWords(),
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "\u20b1 ${(item.price * 1.03).ceil().toStringAsFixed(2)}",
                          style: TextStyle(
                              fontFamily: "",
                              color: const Color(0xFFABABAB),
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            if (!item.isAvailable) ...{
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.1),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                          color: red.withOpacity(1),
                          borderRadius: BorderRadius.circular(60)),
                      child: Text(
                        "Not Available",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            },
          ],
        ),
      ),
    );
  }
}
