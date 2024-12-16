import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_details.dart';

class BuildSearchByStore extends StatelessWidget {
  const BuildSearchByStore(
      {super.key, required this.dataProvider, required this.isWholePage});
  final FutureProvider<List<Merchant>> dataProvider;
  final bool isWholePage;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Consumer(builder: (context, ref, child) {
      final result = ref.watch(dataProvider);

      return result.when(
          data: (data) {
            if (data.isEmpty) {
              return SizedBox(
                width: double.infinity,
                height: isWholePage ? size.height - 250 : 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/rider.png",
                      height: 100,
                    ),
                    const Gap(20),
                    Text("No result found")
                  ],
                ),
              );
            }
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: data
                  .map((e) => storeCard(
                      merchant: e,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StoreDetailsPage(model: e),
                          ),
                        );
                      }))
                  .toList(),
            );
          },
          error: (e, s) => Container(),
          loading: () => SizedBox(
                width: double.infinity,
                height: isWholePage ? size.height - 250 : 200,
                child: CustomLoader(
                  color: const Color(0xFF3F3F3F),
                  label: "Searching shops or restaurants",
                ),
              ));
    });
  }

  Widget storeCard({required Merchant merchant, Function()? onTap}) =>
      LayoutBuilder(
        builder: (_, c) {
          return GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Hero(
                      tag: merchant.id,
                      child: CachedNetworkImage(
                        imageUrl: merchant.featuredPhoto ??
                            "https://customer.nomnomdelivery.com/images/no_image_placeholder.jpg",
                        fit: BoxFit.cover,
                        height: c.maxHeight * .63,
                        width: c.maxWidth,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            merchant.name.capitalizeWords(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            merchant.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600),
                          )
                        ],
                      ),
                    )
                    // Container(
                    //   height: c.maxHeight * .6,
                    //   color: Colors.red,
                    // )
                  ],
                ),
              ),
            ),
          );
        },
      );
}
