import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/extensions/date_ext.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/cart_button.dart';
import 'package:nomnom/app/widgets/debounced_textfield.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/app_service/location_permission.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/services/firebase/push_notification_handler.dart';
import 'package:nomnom/views/navigation_children/drawer_display.dart';
import 'package:nomnom/views/navigation_children/order_status_card.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/search_menu_page.dart';
import 'package:nomnom/views/navigation_children/show_addresses.dart';

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key});

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage>
    with ColorPalette {
  final PushNotificationHandler _fcm = PushNotificationHandler.instance;
  late final NomnomLocationPermission _locationPermission =
      NomnomLocationPermission.instance(ref);
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

  Future<void> initialLocation() async {
    await _locationPermission.onGrantedCallback();
  }

  Future<void> initFCMListener() async {
    await _fcm.initialize((
      bool f,
    ) async {
      if (f) {
        await _fcm.onMessageListen(context, onOrderReceived: () {
          print("ORDER REFETCH!");
          // ref.invalidate(futureActiveOrderProvider);
          // ref.invalidate(futureHistoryOrderProvider);
        });
      }
    }, onFcmTokenCreated: (String token) async {
      final currentUser = ref.watch(currentUserProvider);
      if (currentUser == null) return;
      await _firebase.addFcmToken(currentUser.id, token);
      final tokens = await _firebase.getTokens(currentUser.id);
      print("MY TOKENS: $tokens");
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.value([initFCMListener(), initialLocation()]);
      initStream();
      // await _fcm.initialize();
      // await initialLocation();
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
    // final cartFuture = ref.watch(futureCartProvider);
    ref.watch(futureClientPointsProvider);
    final UserAddress? myLocation = ref.watch(selectedLocationProvider);
    final Size size = MediaQuery.of(context).size;
    final List<UserAddress>? addresses = ref.watch(addressChoiceProvider);
    // final bool showAddress = ref.watch(addressVisibilityProvider);
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          drawer: DrawerDisplay(),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
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
                                              isScrollControlled: true,
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
                                                      maxWidth:
                                                          size.width * .35),
                                                  child: Text(
                                                    "No location, check permission",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                      maxWidth:
                                                          size.width * .35),
                                                  child: Text(
                                                    myLocation.city
                                                        .capitalizeWords(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                  hintText: "Search for restaurants & items",
                                  onDebouncedChange: (text) {
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
                // const Gap(20),
                // // CAROUSEL FOR NEWS
                // Container(
                //   width: double.infinity,
                //   height: 200,
                //   color: Colors.red,
                // ),
                const Gap(25),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    children: [
                      OrderStatusCard(),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            '/navigation-page/restaurant-listing-page',
                          );
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 150,
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
                                    color: orangePalette,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "nom nom",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                height: 1),
                                          ),
                                          Text(
                                            "Food Delivery",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 22,
                                                height: 1),
                                          ),
                                          Text(
                                            "We deliver your cravings",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        "30+ Restaurants",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                bottom: 10,
                                child: Image.asset(
                                    "assets/images/food_delivery.png"),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                      GridView.count(
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        childAspectRatio: 1.35,
                        padding: const EdgeInsets.all(0),
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          card(
                            imagePath: "assets/images/food_pick-up.png",
                            title: "nom nom",
                            label: "Food\nPick-Up",
                            onTap: () {},
                          ),
                          card(
                            imagePath: "assets/images/grocery.png",
                            title: "Coming Soon",
                            subLabel: "nom nom",
                            label: "Grocery",
                          ),
                          card(
                            imagePath: "assets/images/medicine.png",
                            title: "Coming Soon",
                            subLabel: "nom nom",
                            label: "Medicine",
                          ),
                          card(
                            imagePath: "assets/images/document.png",
                            title: "Coming Soon",
                            subLabel: "nom nom",
                            label: "Document",
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 20,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  card({
    required String imagePath,
    required String title,
    required String label,
    String? subLabel,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, c) => SizedBox(
            width: c.maxWidth,
            height: c.maxHeight,
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: orangePalette,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                        const Spacer(),
                        if (subLabel != null) ...{
                          Text(
                            subLabel,
                            style: TextStyle(
                              height: 1,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          )
                        },
                        Text(
                          label,
                          style: TextStyle(
                            height: 1,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 5,
                  child: Image.asset(imagePath),
                )
              ],
            ),
          ),
        ),
      );
}
