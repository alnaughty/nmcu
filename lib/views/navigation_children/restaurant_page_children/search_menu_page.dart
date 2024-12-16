import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/debounced_textfield.dart';
import 'package:nomnom/models/merchant/menu_item.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/store_api.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/build_search_by_menu.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/build_search_by_store.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/menu_details.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/popular_card.dart';

class SearchMenuPage extends ConsumerStatefulWidget {
  const SearchMenuPage(
      {super.key,
      required this.keyword,
      required this.merchantID,
      required this.searchType});
  final String? keyword;
  final int? merchantID;
  final int searchType; // 0 = both, 1= store only, 2=item only
  @override
  ConsumerState<SearchMenuPage> createState() => _SearchMenuPageState();
}

class _SearchMenuPageState extends ConsumerState<SearchMenuPage>
    with ColorPalette {
  static final _keywordProvider = StateProvider<String>((ref) => "");
  static final StoreApi _api = StoreApi();
  // late String keyword = widget.keyword ?? "";
  // late final T
  final dataProvider = FutureProvider<List<MenuItem>>(
    (ref) async => await _api.searchMenu(
      keyword: ref.watch(_keywordProvider),
    ),
  );
  final storeProvider = FutureProvider<List<Merchant>>(
    (ref) async {
      final currentLocation = ref.watch(currentLocationProvider);
      return await _api.search(
          keyword: ref.watch(_keywordProvider), city: currentLocation?.city);
    },
  );
  // listenKeywordChange() {
  //   ref.listen(_keywordProvider, (prev, next) {
  //     if (prev != next) {
  //       print("NEW KEYWORD: $next");
  //       print("SEARCHABLE : $next");
  //     }
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // listenKeywordChange();
      ref
          .read(_keywordProvider.notifier)
          .update((r) => widget.keyword?.capitalize() ?? "");
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = ref.watch(_keywordProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFEFEFEF),
        appBar: AppBar(
          title: Text(
            "Search ${widget.searchType == 0 ? "shops or item" : widget.searchType == 1 ? "shops" : "items"}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              DebouncedTextField(
                onDebouncedChange: (text) {
                  ref.read(_keywordProvider.notifier).update((r) => text);
                  ref.invalidate(dataProvider);
                },
                hintText:
                    "Search ${widget.searchType == 0 ? "shops or item" : widget.searchType == 1 ? "shops" : "items"}",
                labelText: "Search",
                initText: widget.keyword,
              ),
              const Gap(15),
              if (widget.searchType == 0 || widget.searchType == 1) ...{
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.searchType == 0) ...{
                      Text(
                        "Store found found for '$keyword'",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(10),
                    },
                    BuildSearchByStore(
                        dataProvider: storeProvider,
                        isWholePage: widget.searchType == 1)
                  ],
                )
              },
              // Text("data")
              if (widget.searchType == 0 || widget.searchType == 2) ...{
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.searchType == 0) ...{
                      Text(
                        "Menu found for '$keyword'",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(10)
                    },
                    BuildSearchByMenu(
                      dataProvider: dataProvider,
                      isWholePage: widget.searchType == 2,
                    )
                  ],
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}
