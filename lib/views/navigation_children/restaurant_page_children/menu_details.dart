import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/cart_button.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/custom_radio_button.dart';
import 'package:nomnom/app/widgets/quantity_button.dart';
import 'package:nomnom/models/merchant/menu_item.dart';
import 'package:nomnom/models/merchant/menu_item_details.dart';
import 'package:nomnom/models/merchant/option.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/app.dart';
import 'package:nomnom/services/api/cart_api.dart';
import 'package:nomnom/services/api/store_api.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/options_builder.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/visit_shop.dart';

class MenuDetails extends ConsumerStatefulWidget {
  const MenuDetails({super.key, required this.item});
  final MenuItem item;
  @override
  ConsumerState<MenuDetails> createState() => _MenuDetailsState();
}

class _MenuDetailsState extends ConsumerState<MenuDetails> with ColorPalette {
  // late final Map<String, dynamic> typeConfig =
  //     jsonDecode(widget.item.typeConfig);
  static final StoreApi _api = StoreApi();
  late final detailsProvider = FutureProvider<MenuItemDetails?>((ref) async {
    return await _api.getMenuDetails(widget.item.id);
  });
  final CartApi _cartApi = CartApi();
  int quantity = 1;
  List<OptionSelection> _selectedOptions = [];
  Widget titler(
          {Widget? icon,
          required String title,
          required String subtitle,
          CrossAxisAlignment alignment = CrossAxisAlignment.start}) =>
      LayoutBuilder(builder: (context, c) {
        return Column(
          crossAxisAlignment: alignment,
          children: [
            Row(
              mainAxisAlignment: alignment == CrossAxisAlignment.start
                  ? MainAxisAlignment.start
                  : alignment == CrossAxisAlignment.center
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.end,
              children: [
                icon ?? Container(),
                if (icon != null) ...{const Gap(5)},
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: c.maxWidth * .8),
                  child: Tooltip(
                    message: title,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(.5)),
            )
          ],
        );
      });
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    print(widget.item.typeConfig);
    final details = ref.watch(detailsProvider);
    return PopScope(
      canPop: !isLoading,
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            color: textField,
                            height: 300,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Hero(
                                    tag: widget.item.photoUrl,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.item.photoUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  child: SafeArea(
                                    bottom: false,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        BackButton(),
                                        CartButton(
                                          mainColor: Colors.black,
                                          textColor: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                    bottom:
                                        BorderSide(width: 1, color: darkGrey))),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.item.name.capitalizeWords(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        widget.item.description.capitalize(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFABABAB)),
                                      )
                                    ],
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  "₱ ${(widget.item.price * 1.03).ceil().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          details.when(
                            data: (data) {
                              if (data == null) return Container();
                              return Column(
                                children: [
                                  const Gap(20),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: textField.withOpacity(.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: titler(
                                              title:
                                                  "${widget.item.preparationTime} min",
                                              icon: Icon(
                                                Icons.access_time_outlined,
                                                color: darkGrey,
                                                size: 15,
                                              ),
                                              subtitle: "Prep. Time"),
                                        ),
                                        Expanded(
                                          child: titler(
                                              title: data.category.name,
                                              // title: widget.item.preparationDays <= 0
                                              //     ? "< a day"
                                              //     : "${widget.item.preparationDays} day${widget.item.preparationDays > 1 ? "s" : ""}",
                                              alignment:
                                                  CrossAxisAlignment.center,
                                              icon: Icon(
                                                Icons.category,
                                                color: darkGrey,
                                                size: 15,
                                              ),
                                              subtitle: "Category"),
                                        ),
                                        Expanded(
                                          child: titler(
                                              alignment: CrossAxisAlignment.end,
                                              title:
                                                  "${widget.item.quantityLimit}",
                                              icon: Icon(
                                                Icons.countertops,
                                                color: darkGrey,
                                                size: 15,
                                              ),
                                              subtitle: "Limit per order"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (data.options.isNotEmpty) ...{
                                    const Gap(10),
                                    ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        final Option option = data.options[i];
                                        return OptionsBuilder(
                                            callback: (selectedVariation) {
                                              // final OptionSelection? selectedOption =
                                              //     _selectedOptions.firstOrNull(
                                              //         (e) => e.optionId == option.id);
                                              final OptionSelection?
                                                  selectedOpt = _selectedOptions
                                                      .where((e) =>
                                                          e.optionId ==
                                                          selectedVariation
                                                              .optionId)
                                                      .firstOrNull;
                                              // print(
                                              //     "SELECTED VARIATION : $selectedVariation");
                                              if (selectedOpt == null) {
                                                _selectedOptions
                                                    .add(selectedVariation);
                                                print(
                                                    "ADD ${selectedVariation.optionName} - ${selectedVariation.variation.title}");
                                              } else {
                                                print(
                                                    "UPDATE ${selectedVariation.optionName} - ${selectedVariation.variation.title}");
                                                int s = _selectedOptions
                                                    .indexOf(selectedOpt);
                                                _selectedOptions[s] =
                                                    selectedVariation;
                                              }

                                              if (mounted) setState(() {});
                                            },
                                            option: option);
                                      },
                                      separatorBuilder: (_, i) => const Gap(10),
                                      itemCount: data.options.length,
                                    )
                                  },
                                  const Gap(10),
                                  VisitShop(
                                    store: data.merchant,
                                  ),
                                  const Gap(10),
                                ],
                              );
                            },
                            error: (error, s) => Container(),
                            loading: () => SizedBox(
                              height: 300,
                              child: CustomLoader(
                                color: darkGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Subtotal:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "₱ ${(_selectedOptions.map((e) => e.variation.price).fold(0.0, (sum, price) => sum + price) + (widget.item.price * 1.03).ceil() * quantity).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontFamily: "",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              QuantityButton(
                                limit: widget.item.quantityLimit,
                                value: quantity,
                                callback: (int i) {
                                  setState(() {
                                    quantity = i;
                                  });
                                },
                              ),
                              const Gap(10),
                              Expanded(
                                child: MaterialButton(
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () async {
                                    late double subtotal = _selectedOptions
                                            .map((e) => e.variation.price)
                                            .fold(0.0,
                                                (sum, price) => sum + price) +
                                        ((widget.item.price * 1.03).ceil() *
                                            quantity);
                                    print(subtotal);
                                    print(_selectedOptions);
                                    // if()
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await _cartApi.add(
                                      menuItemID: widget.item.id,
                                      quantity: quantity,
                                      subtotal: subtotal,
                                      optionSelection: _selectedOptions,
                                      orderType: 1,
                                    );
                                    ref.invalidate(futureCartProvider);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  color: orangePalette,
                                  child: Center(
                                    child: Text(
                                      "Add to cart",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (isLoading) ...{
            Positioned.fill(
              child: Material(
                color: Colors.black.withOpacity(.5),
                child: Center(
                  child: CustomLoader(
                    label: "Adding to cart, please wait",
                    // color: ,
                  ),
                ),
              ),
              // child: Container(
              //   color: Colors.black.withOpacity(.5),
              //   child: Center(
              // child: CustomLoader(
              //   label: "Please wait",
              // ),
              //   ),
              // ),
            )
          }
        ],
      ),
    );
  }
}
