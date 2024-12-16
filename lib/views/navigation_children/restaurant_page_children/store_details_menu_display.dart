import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/cart_button.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/merchant/categorized_menu.dart';
import 'package:nomnom/models/merchant/menu_item.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/services/api/store_api.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/menu_details.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/popular_card.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_details.dart';

class StoreDetailsMenuPage extends ConsumerStatefulWidget {
  const StoreDetailsMenuPage(
      {super.key,
      required this.model,
      required this.changePage,
      required this.dataProvider,
      required this.sections,
      required this.tabs});
  final Merchant model;
  final VoidCallback changePage;
  final FutureProvider<MenuResult> dataProvider;
  final List<Tab> tabs;
  final List<GlobalKeySections> sections;
  @override
  ConsumerState<StoreDetailsMenuPage> createState() =>
      _StoreDetailsMenuPageState();
}

class _StoreDetailsMenuPageState extends ConsumerState<StoreDetailsMenuPage>
    with ColorPalette, SingleTickerProviderStateMixin {
  // bool showTitle = false;
  double titleOpacity = 0;
  late final TimeOfDay endTime =
      widget.model.currentSchedule.endTime.toTimeOfDay;

  late final List<Tab> tabs = widget.tabs;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(() {
      double offset = _scrollController.offset;
      titleOpacity = (offset > 217) ? 1.0 : (offset / 217).clamp(0.0, 1.0);
      List<GlobalKeySections> visibleKeys = [];
      for (GlobalKeySections section in _sections) {
        final RenderObject? renderObject =
            section.key.currentContext?.findRenderObject();
        if (renderObject != null) {
          final RenderBox renderBox = renderObject as RenderBox;
          final Offset position = renderBox.localToGlobal(Offset.zero);
          final Size size = renderBox.size;

          // Adjust visibility check based on your specific needs
          // For example, you could check if the widget is fully visible, partially visible, or completely offscreen.
          final _isTargetVisible = position.dy >= 0 &&
              position.dy + size.height <= MediaQuery.of(context).size.height;
          if (_isTargetVisible) {
            visibleKeys.add(section);
          }
        }
      }
      controller.animateTo(visibleKeys.first.index);
      setState(() {});
    });
  late final List<GlobalKeySections> _sections = widget.sections;
  late TabController controller =
      TabController(length: tabs.length, vsync: this);

  // void _onTabChanged() {
  //   if (controller.indexIsChanging) {
  //     // Get the key for the section and scroll to it
  // final sectionKey = _sections[tabs[controller.index].text]!;
  // Scrollable.ensureVisible(
  //   sectionKey.currentContext!,
  //   duration: Duration(milliseconds: 300),
  //   curve: Curves.easeInOut,
  // );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final menuResult = ref.watch(widget.dataProvider);
    final Size size = MediaQuery.of(context).size;
    final double appBarExpandedSize = 300;
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            actions: [
              CartButton(
                mainColor: Colors.black,
                textColor: Colors.white,
              ),
            ],
            centerTitle: false,
            title: Opacity(
              opacity: titleOpacity,
              child: Text(
                widget.model.name.capitalizeWords(),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            elevation: 1,
            collapsedHeight: 56,
            expandedHeight: appBarExpandedSize,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [
                StretchMode.zoomBackground,
                StretchMode.blurBackground
              ],
              background: AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(builder: (context, c) {
                  return Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      Hero(
                        tag: widget.model.id,
                        child: CachedNetworkImage(
                          imageUrl: widget.model.featuredPhoto ??
                              "https://customer.nomnomdelivery.com/images/no_image_placeholder.jpg",
                          fit: BoxFit.cover,
                          height: c.maxHeight * 0.55,
                          width: size.width,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: c.maxHeight * .5,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: widget.model.photoUrl,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.model.photoUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Gap(15),
                              Expanded(
                                child: LayoutBuilder(builder: (context, cc) {
                                  return Container(
                                    padding: const EdgeInsets.only(top: 35),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Hero(
                                                tag: widget.model.name,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  elevation: 0,
                                                  child: Text(
                                                    widget.model.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .fontSize!,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Gap(10),
                                            GestureDetector(
                                              onTap: widget.changePage,
                                              child: Icon(Icons.chevron_right),
                                            )
                                          ],
                                        ),
                                        Hero(
                                          tag: widget.model.address,
                                          child: Material(
                                            color: Colors.transparent,
                                            elevation: 0,
                                            child: Text(
                                              widget.model.address,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black
                                                      .withOpacity(.5)
                                                  // fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Material(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          child: Hero(
                                            tag:
                                                widget.model.currentSchedule.id,
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: widget
                                                              .model
                                                              .currentSchedule
                                                              .isOpen
                                                          ? green
                                                          : red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  child: Text(
                                                    widget.model.currentSchedule
                                                            .isOpen
                                                        ? "Open"
                                                        : "Close",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                const Gap(10),
                                                Text(
                                                  "Until ${endTime.format(context)}",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black
                                                          .withOpacity(.5),
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 56,
                                        )
                                      ],
                                    ),
                                  );
                                }),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
            backgroundColor: scaffoldColor,
            bottom: menuResult.when(
              data: (data) {
                return PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      onTap: (int index) {
                        final sectionKey = _sections[index].key;
                        Scrollable.ensureVisible(
                          sectionKey.currentContext!,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      isScrollable: true,
                      unselectedLabelColor: Colors.black,
                      labelColor: orangePalette,
                      indicatorColor: orangePalette,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabAlignment: TabAlignment.start,
                      indicatorWeight: 4,
                      tabs: tabs,
                      controller: controller,
                      dividerColor: const Color.fromRGBO(0, 0, 0, 0),
                    ),
                  ),
                );
              },
              error: (e, s) => null,
              loading: () => PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: Center(
                  child: CustomLoader(
                    color: darkGrey,
                    label: "Fetching data",
                  ),
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate(
            [
              menuResult.when(
                data: (data) {
                  if (data.categorizedMenu.isEmpty &&
                      data.popularItems.isEmpty) {
                    return Container();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.popularItems.isNotEmpty) ...{
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                key: _sections.first.key,
                                children: [
                                  Icon(
                                    Icons.whatshot,
                                    color: orangePalette,
                                  ),
                                  const Gap(10),
                                  Text(
                                    "Popular now",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              SizedBox(
                                height: 235,
                                width: double.infinity,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (_, i) {
                                    final MenuItem item = data.popularItems[i];
                                    return PopularCard(
                                      item: item,
                                      width: 160,
                                    );
                                  },
                                  separatorBuilder: (_, i) => const Gap(10),
                                  itemCount: data.popularItems.length,
                                ),
                              ),
                              const Gap(10)
                            ],
                          ),
                        },
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, i) {
                            final int sectionIndex =
                                data.popularItems.isEmpty ? i : i + 1;
                            final CategorizedMenu e = data.categorizedMenu[i];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_sections[sectionIndex].name),
                                Text(
                                  key: _sections[sectionIndex].key,
                                  e.name.capitalizeWords(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const Gap(10),
                                ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (_, index) {
                                    final MenuItem item = e.items[index];
                                    // if (item.type == 3) {
                                    //   return Container();
                                    // }
                                    return SizedBox(
                                      height: 72,
                                      width: double.infinity,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ListTile(
                                              onTap: item.isAvailable
                                                  ? () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  MenuDetails(
                                                                      item:
                                                                          item)));
                                                    }
                                                  : null,
                                              trailing: SizedBox(
                                                width: 60,
                                                height: 60,
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: Hero(
                                                        tag: item.photoUrl,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              item.photoUrl,
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              contentPadding: item.isAvailable
                                                  ? EdgeInsets.zero
                                                  : EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              titleTextStyle: TextStyle(
                                                fontFamily: "Poppins",
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              title: Text(
                                                item.name.capitalizeWords(),
                                              ),
                                              subtitle: Text.rich(
                                                TextSpan(
                                                    text:
                                                        "₱ ${(item.price * 1.03).ceil().toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                        fontFamily: "",
                                                        color: const Color(
                                                            0xFFABABAB),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    children: [
                                                      if (item.orderType ==
                                                          2) ...{
                                                        TextSpan(
                                                            text: " Pre-order",
                                                            style: TextStyle(
                                                              color:
                                                                  orangePalette,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ))
                                                      },
                                                    ]),
                                              ),
                                            ),
                                          ),
                                          if (!item.isAvailable) ...{
                                            Positioned.fill(
                                                child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              child: Center(
                                                child: Transform.rotate(
                                                  angle: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 7),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            red.withOpacity(1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(60)),
                                                    child: Text(
                                                      "Not Available",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ))
                                          },
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, x) => const Gap(10),
                                  itemCount: e.items.length,
                                )
                              ],
                            );
                          },
                          separatorBuilder: (_, i) => const Gap(20),
                          itemCount: data.categorizedMenu.length,
                        ),
                        // ...data.categorizedMenu.map(
                        //   (e) => ListView.separated(
                        //     padding: EdgeInsets.zero,
                        //     physics:
                        //         const NeverScrollableScrollPhysics(),
                        //     shrinkWrap: true,
                        //     itemBuilder: itemBuilder,
                        //     separatorBuilder: separatorBuilder,
                        //     itemCount: itemCount,
                        //   ),
                        // )
                        // ...data.categorizedMenu.map(
                        // (e) => ,
                        // )
                      ],
                    ),
                  );
                },
                error: (e, s) => Container(),
                loading: () => SizedBox(
                  height: size.height - 400,
                  width: size.width,
                  child: Center(
                    child: CustomLoader(
                      label: "Fetching menu",
                      color: grey,
                    ),
                  ),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
