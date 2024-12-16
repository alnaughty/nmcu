import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/merchant/menu_item.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/menu_details.dart';

class BuildSearchByMenu extends StatelessWidget {
  const BuildSearchByMenu(
      {super.key, required this.dataProvider, required this.isWholePage});
  final FutureProvider<List<MenuItem>> dataProvider;
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
          return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) {
                final MenuItem item = data[i];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MenuDetails(item: item)));
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: CachedNetworkImage(
                    imageUrl: item.photoUrl,
                    height: 60,
                    width: 60,
                  ),
                  title: Text(
                    item.name.capitalizeWords(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              separatorBuilder: (_, i) => const Gap(10),
              itemCount: data.length);
          // return GridView.count(

          //   mainAxisSpacing: 10,
          //   crossAxisSpacing: 10,
          //   crossAxisCount: 2,
          //   children: data
          //       .map(
          //         (e) => ListTile(
          //           onTap: () {},
          //           contentPadding: EdgeInsets.zero,
          //         ),
          //       )
          //       .toList(),
          // );
        },
        error: (e, s) => Container(),
        loading: () => SizedBox(
          width: double.infinity,
          height: isWholePage ? size.height - 250 : 200,
          child: CustomLoader(
            color: const Color(0xFF3F3F3F),
            label: "Searching menu",
          ),
        ),
      );
    });
  }
}
