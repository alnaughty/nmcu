import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/date_ext.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/cart_button.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/debounced_textfield.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/raw_category.dart';
import 'package:nomnom/models/user/current_address.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/store_api.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/views/navigation_children/order_status_card.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/search_menu_page.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_card.dart';
import 'package:nomnom/views/navigation_children/show_addresses.dart';

class RestaurantPage extends ConsumerStatefulWidget {
  const RestaurantPage({super.key});

  @override
  ConsumerState<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends ConsumerState<RestaurantPage>
    with ColorPalette {
  static final FirebaseFirestoreSupport _firebase = FirebaseFirestoreSupport();
  late final StreamSubscription _deliveryStreamSubscription;
  late final Stream<List<DeliveryModel>> _deliveryStream;

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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserAddress? myLocation = ref.watch(selectedLocationProvider);
    final restaurantResult = ref.watch(navigationRestaurantFutureProvider);
    final List<UserAddress>? addresses = ref.watch(addressChoiceProvider);
    // final List<Merchant> storeListing = ref.watch(navigationRestaurantProvider);
    final Size size = MediaQuery.of(context).size;
    final categories = ref.watch(exploreCategoriesProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFEFEFEF),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'navigation-appbar',
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    width: double.infinity,
                    // padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: orangePalette,
                      // image: const DecorationImage(
                      //   fit: BoxFit.cover,
                      //   image: AssetImage(
                      //     "assets/images/vector_background.png",
                      //   ),
                      // ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            "assets/images/vector_background.png",
                            color: Colors.white.withOpacity(.5),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          children: [
                            PreferredSize(
                              preferredSize: Size.fromHeight(56),
                              child: AppBar(
                                iconTheme: IconThemeData(
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                title: InkWell(
                                  onTap: addresses == null
                                      ? null
                                      : () async {
                                          await showModalBottomSheet(
                                            context: context,
                                            builder: (_) => ShowAddresses(),
                                          );
                                        },
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: size.width * .45,
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (myLocation == null) ...{
                                              Text(
                                                "Checking location",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: size.width * .35),
                                                child: Text(
                                                  "No location, check permission",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            } else ...{
                                              Text(
                                                myLocation.title.capitalize(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: size.width * .35),
                                                child: Text(
                                                  myLocation.city
                                                      .capitalizeWords(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            }
                                          ],
                                        ),
                                        if (addresses != null &&
                                            myLocation != null) ...{
                                          const Gap(10),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.white,
                                          )
                                        }
                                      ],
                                    ),
                                  ),
                                ),
                                centerTitle: false,
                                actions: [
                                  CartButton(),
                                ],
                              ),
                            ),
                            // PreferredSize(
                            //   preferredSize: Size.fromHeight(56),
                            //   child: AppBar(
                            //     iconTheme: IconThemeData(
                            //       color: Colors.white,
                            //     ),
                            //     backgroundColor: Colors.transparent,
                            //     elevation: 0,
                            //     title: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         Text(
                            //           "Current location",
                            //           style: TextStyle(
                            //             fontSize: 12,
                            //             color: Colors.white,
                            //             fontWeight: FontWeight.w500,
                            //           ),
                            //         ),
                            //         if (myLocation == null) ...{
                            //           Text(
                            //             "No location, check permission",
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               fontWeight: FontWeight.w500,
                            //               color: Colors.white,
                            //             ),
                            //           )
                            //         } else ...{
                            //           Text(
                            //             myLocation.city,
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               fontWeight: FontWeight.w600,
                            //               color: Colors.white,
                            //             ),
                            //           )
                            //         }
                            //       ],
                            //     ),
                            //     centerTitle: false,
                            //     actions: [
                            //       CartButton(),
                            //     ],
                            //   ),
                            // ),
                            const Gap(10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: DebouncedTextField(
                                textColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.white.withOpacity(1),
                                ),
                                hintText: "Search for restaurants or menu",
                                onDebouncedChange: (text) {
                                  if (text.isEmpty) return;
                                  // print("TEXT : $text");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SearchMenuPage(
                                        keyword: text,
                                        searchType: 0,
                                        merchantID: null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Gap(15),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(20),
              categories.when(
                  data: (data) {
                    if (data.isEmpty) return Container();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Explore Categories",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          height: 100,
                          width: size.width,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, i) {
                              final RawCategory category = data[i];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SearchMenuPage(
                                        keyword: category.name,
                                        searchType: 0,
                                        merchantID: null,
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 75,
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: category.photoUrl,
                                          height: 75,
                                          width: 75,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            category.name.capitalizeWords(),
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                height: 1),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, i) => const Gap(10),
                            itemCount: data.length,
                          ),
                        ),
                        const Gap(10),
                      ],
                    );
                  },
                  error: (error, s) => Container(),
                  loading: () => Container()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderStatusCard(),
                    Text(
                      "All restaurants",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(10),
                    restaurantResult.when(
                      data: (storeListing) {
                        if (storeListing.isEmpty) {
                          return SizedBox(
                            height: size.height - 280,
                            width: double.infinity,
                            // color: Colors.red,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/rider.png",
                                  width: size.width * .35,
                                ),
                                const Gap(10),
                                Text(
                                  "No stores found in your location",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: darkGrey),
                                )
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (_, i) {
                            final Merchant store = storeListing[i];
                            return StoreCard(store: store);
                          },
                          separatorBuilder: (_, i) => const Gap(10),
                          itemCount: storeListing.length,
                        );
                      },
                      error: (_, s) => Container(),
                      loading: () => SizedBox(
                        height: size.height - 400,
                        child: CustomLoader(
                          label: "Fetching stores",
                          color: darkGrey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SafeArea(
                top: false,
                child: SizedBox(
                  height: 20,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
