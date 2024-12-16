import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/feedback/store_feedback.dart';
import 'package:nomnom/models/merchant/categorized_menu.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/merchant/promo.dart';
import 'package:nomnom/services/api/store_api.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_details_content_page.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/store_details_menu_display.dart';

class GlobalKeySections {
  final int index;
  final GlobalKey key;
  final String name;
  const GlobalKeySections(
      {required this.index, required this.key, required this.name});
}

class StoreDetailsPage extends ConsumerStatefulWidget {
  const StoreDetailsPage({super.key, required this.model});
  final Merchant model;
  @override
  ConsumerState<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends ConsumerState<StoreDetailsPage>
    with TickerProviderStateMixin {
  List<Tab> menutabs = [];
  List<GlobalKeySections> _sections = [];
  static final StoreApi _api = StoreApi();

  late final ratingProvider = FutureProvider<StoreFeedback>((ref) async {
    final result = await _api.getRatingsAndFeedback(widget.model.id);
    return result;
  });
  late final promoProvider = FutureProvider<List<PromoModel>>((ref) async {
    return await _api.getOngoingPromo(ids: [widget.model.id]);
  });
  late final dataProvider = FutureProvider<MenuResult>((ref) async {
    // if()
    final result = await _api.getMenu(widget.model.id);
    // result.popularItems.removeWhere((e) => e.type == 3);

    if (result.popularItems.isNotEmpty) {
      menutabs.add(
        Tab(
          text: "Popular",
        ),
      );
      // _sections.addAll({"Popular": GlobalKey()});
      _sections
          .add(GlobalKeySections(index: 0, key: GlobalKey(), name: "Popular"));
    }
    if (result.categorizedMenu.isNotEmpty) {
      int index = result.popularItems.isEmpty ? 0 : 1;
      // for(int i = initIndex; i<res)
      for (CategorizedMenu cats in result.categorizedMenu) {
        final GlobalKey nKey = GlobalKey();
        // _sections.addAll({cats.name.capitalizeWords(): GlobalKey()});
        _sections.add(GlobalKeySections(
            index: index, key: nKey, name: cats.name.capitalizeWords()));
        menutabs.add(Tab(
          text: cats.name.capitalizeWords(),
        ));
        index += 1;
        // for(MenuItem item in cats.items){
        // }
      }
    }
    print("SECTIONS : $_sections");

    // setState(() {
    //   controller = TabController(length: menutabs.length, vsync: this);
    // });
    // controller.addListener(_onTabChanged);
    return result;
  });

  // // final dataProvider = FutureProvider<MerchantDetails>((ref) {});
  late final TabController _controller = TabController(length: 2, vsync: this);
  @override
  Widget build(BuildContext context) {
    final res = ref.watch(dataProvider);
    final Size size = MediaQuery.of(context).size;
    return res.when(
        data: (data) {
          late final List<Widget> _contents = [
            StoreDetailsMenuPage(
              model: widget.model,
              tabs: menutabs,
              sections: _sections,
              changePage: () {
                _controller.animateTo(1);
              },
              dataProvider: dataProvider,
            ),
            StoreDetailsContentPage(
              changePage: () {
                _controller.animateTo(0);
              },
              promoProvider: promoProvider,
              model: widget.model,
              rateProvider: ratingProvider,
            )
          ];
          return TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            children: _contents,
          );
        },
        error: (e, s) => Container(),
        loading: () => Material(
              color: Colors.transparent,
              elevation: 0,
              child: Container(
                color: Colors.white,
                width: size.width,
                height: size.height,
                child: Center(
                  child: CustomLoader(
                    color: Colors.black.withOpacity(.5),
                    label: "Loading details",
                  ),
                ),
              ),
            ));
  }
}
