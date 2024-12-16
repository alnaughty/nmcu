import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/cart_menu_listing.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/checkout_page.dart';

class CustomStep {
  final String title;
  final int index;
  bool isEnabled;
  CustomStep(
      {required this.isEnabled, required this.title, required this.index});
}

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage>
    with ColorPalette, SingleTickerProviderStateMixin {
  int currentStep = 2;
  final List<CustomStep> steps = [
    CustomStep(isEnabled: false, title: "Menu", index: 1),
    CustomStep(isEnabled: false, title: "Bag", index: 2),
    CustomStep(isEnabled: false, title: "Checkout", index: 3),
  ];
  CheckoutData? checkoutData;
  late final TabController _controller =
      TabController(length: steps.length, vsync: this, initialIndex: 1);

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(cartLoadingProvider);
    return PopScope(
      canPop: !isLoading,
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              backgroundColor: Color(0xFFF8F8F8),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: Container(
                  color: orangePalette,
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
                          AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            iconTheme: IconThemeData(
                              color: Colors.white,
                            ),
                            centerTitle: true,
                            title: Text(
                              "Bag",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 64,
                            width: double.infinity,
                            // color: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: LayoutBuilder(builder: (context, c) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: 64 * .3,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 35),
                                      width: double.infinity,
                                      height: 3,
                                      color: Colors.white.withOpacity(.5),
                                      child:
                                          LayoutBuilder(builder: (context, cc) {
                                        double containerWidth = 0;
                                        if (currentStep == 2) {
                                          containerWidth = cc.maxWidth * .5;
                                        } else if (currentStep == 3) {
                                          containerWidth = cc.maxWidth;
                                        } else {
                                          containerWidth = 0;
                                        }
                                        return Stack(
                                          children: [
                                            Container(
                                              height: 3,
                                              width: containerWidth,
                                              color: Colors.white,
                                            )
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                  Positioned(
                                    top: 64 * .05,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: steps
                                          .map((e) => InkWell(
                                                onTap: () {
                                                  // print(e.index);
                                                  if (currentStep > e.index) {
                                                    if (e.index == 1) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    } else if (e.index == 2) {
                                                      print("ASDAS");
                                                      setState(() {
                                                        currentStep = 2;
                                                        checkoutData = null;
                                                      });
                                                      _controller.animateTo(1);
                                                    }
                                                  }
                                                },
                                                child: SizedBox(
                                                  height: 64,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: c.maxHeight * .5,
                                                        height:
                                                            c.maxHeight * .5,
                                                        // padding: const EdgeInsets.symmetric(
                                                        //     vertical: 6, horizontal: 11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: currentStep >=
                                                                  e.index
                                                              ? Colors.white
                                                              : orangePalette,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 1.5),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            e.index.toString(),
                                                            style: TextStyle(
                                                                color: currentStep >=
                                                                        e.index
                                                                    ? orangePalette
                                                                    : Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      ),
                                                      const Gap(5),
                                                      SizedBox(
                                                        width: 62,
                                                        child: Center(
                                                          child: Text(
                                                            e.title,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  )
                                ],
                              );
                            }),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  Container(
                    color: Colors.blue,
                  ),
                  CartMenuListing(
                    // selectedCart: (data) {},
                    onCheckout: (CheckoutData data) async {
                      setState(() {
                        checkoutData = data;
                        currentStep = 3;
                      });
                      // await Future.delayed(800.ms);
                      _controller.animateTo(2);
                    },
                  ),
                  if (checkoutData == null) ...{
                    Container()
                  } else ...{
                    CheckoutPage(
                      data: checkoutData!,
                    ),
                  }
                ],
              ),
            ),
          ),
          if (isLoading) ...{
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.5),
                child: Center(
                  child: CustomLoader(
                    label: "",
                  ),
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
