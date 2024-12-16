import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/size_reporting_widget.dart';
import 'package:nomnom/models/feedback/store_feedback.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/merchant/promo.dart';
import 'package:nomnom/views/auth_children/account_completion_page.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_promo_viewer.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_review_viewer.dart';

class StoreDetailsContentPage extends StatefulWidget {
  const StoreDetailsContentPage(
      {super.key,
      required this.model,
      required this.rateProvider,
      required this.changePage,
      required this.promoProvider});
  final Merchant model;
  final FutureProvider<StoreFeedback> rateProvider;
  final FutureProvider<List<PromoModel>> promoProvider;
  final VoidCallback changePage;
  @override
  State<StoreDetailsContentPage> createState() =>
      _StoreDetailsContentPageState();
}

class _StoreDetailsContentPageState extends State<StoreDetailsContentPage>
    with SingleTickerProviderStateMixin, ColorPalette {
  int currentIndex = 0;
  late final TabController _controller =
      TabController(length: _tabs.length, vsync: this);
  late final List<Widget> _tabContents = [
    StoreReviewViewer(
      provider: widget.rateProvider,
      onSizeChanged: (Size s) {
        setState(() {
          contentSize = s.height;
        });
      },
    ),
    StoreAboutViewer(
      desc: widget.model.description,
    ),
    StorePromoViewer(
      provider: widget.promoProvider,
      onSizeChanged: (Size s) {
        setState(() {
          contentSize = s.height;
        });
      },
    ),
  ];
  final List<Widget> _tabs = [
    Tab(
      text: "Reviews",
    ),
    Tab(
      text: "About",
    ),
    Tab(
      text: "Promo codes",
    )
  ];

  late final TimeOfDay startsAt = widget.model.operatingDays
      .map((d) => d.startTime)
      .reduce((a, b) =>
          a.hour < b.hour || (a.hour == b.hour && a.minute < b.minute) ? a : b);
  late final TimeOfDay endsAt = widget.model.operatingDays
      .map((day) => day.endTime)
      .reduce((a, b) =>
          a.hour > b.hour || (a.hour == b.hour && a.minute > b.minute) ? a : b);

  double contentSize = 100;
  Widget contentBuilder({
    required String title,
    required String value,
    required Widget icon,
    double initTitleSize = 15,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const Gap(
            15,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: initTitleSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: value.isEmpty ? 2 : 1,
                ),
                if (value.isNotEmpty) ...{
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                      color: grey,
                    ),
                  )
                }
              ],
            ),
          )
        ],
      );
  @override
  Widget build(BuildContext context) {
    final double appBarExpandedSize = 300;
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: BackButton(
              onPressed: () {
                widget.changePage();
              },
            ),
            expandedHeight: appBarExpandedSize,
            collapsedHeight: 56,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [
                StretchMode.zoomBackground,
                StretchMode.blurBackground
              ],
              background: AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (context, c) => Column(
                    children: [
                      Hero(
                        tag: widget.model.id,
                        child: CachedNetworkImage(
                          imageUrl: widget.model.featuredPhoto ??
                              "https://customer.nomnomdelivery.com/images/no_image_placeholder.jpg",
                          fit: BoxFit.cover,
                          height: c.maxHeight * 0.45,
                          width: c.maxWidth,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: contentBuilder(
                                  title: widget.model.rating.averageRating
                                      .toStringAsFixed(1),
                                  value: "${widget.model.rating.count} Reviews",
                                  icon: Icon(
                                    Icons.star_border_outlined,
                                    color: orangePalette,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: contentBuilder(
                                  title: widget.model.address,
                                  value: "",
                                  initTitleSize: 14,
                                  icon: Icon(
                                    Icons.location_on_rounded,
                                    color: orangePalette,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: contentBuilder(
                                    title: "Opening Hours",
                                    value:
                                        "${startsAt.format(context)} - ${endsAt.format(context)}",
                                    icon: Icon(
                                      Icons.access_time,
                                      color: orangePalette,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 56,
                      )
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  isScrollable: false,
                  unselectedLabelColor: Colors.black,
                  labelColor: orangePalette,
                  indicatorColor: orangePalette,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 4,
                  tabs: _tabs,
                  controller: _controller,
                  onTap: (i) {
                    setState(() {
                      currentIndex = i;
                    });
                  },
                  dividerColor: const Color.fromRGBO(0, 0, 0, 0),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: 800.ms,
              child: Column(
                children: [
                  _tabContents[currentIndex],
                ],
              ),
              // child: TabBarView(
              //   controller: _controller,
              //   children: _tabContents
              //       .map((e) => OverflowBox(
              //             minHeight: 0,
              //             maxHeight: double.infinity,
              //             child: SizeReportingWidget(
              //                 child: e,
              //                 onSizeChanged: (s) {
              //                   setState(() {
              //                     contentSize = s.height;
              //                   });
              //                 }),
              //           ))
              //       .toList(),
              // ),
            ),
          )
        ],
      ),
    );
  }
}

class StoreAboutViewer extends StatelessWidget {
  const StoreAboutViewer({super.key, required this.desc});
  final String desc;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(20),
          Text(
            desc,
          )
        ],
      ),
    );
  }
}
