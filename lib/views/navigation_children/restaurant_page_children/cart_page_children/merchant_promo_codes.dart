import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/list_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/ticket_clip.dart';
import 'package:nomnom/models/merchant/categorized_promo.dart';
import 'package:nomnom/models/merchant/promo.dart';
import 'package:nomnom/services/api/store_api.dart';

class MerchantPromoCodes extends ConsumerStatefulWidget {
  const MerchantPromoCodes(
      {super.key, required this.merchantID, required this.onPromoSelected});
  final int merchantID;
  final ValueChanged<PromoModel> onPromoSelected;
  @override
  ConsumerState<MerchantPromoCodes> createState() => _MerchantPromoCodesState();
}

class _MerchantPromoCodesState extends ConsumerState<MerchantPromoCodes>
    with ColorPalette {
  final StoreApi _api = StoreApi();
  late final provider =
      FutureProvider<List<CategorizedPromoModel>>((ref) async {
    final res = await _api.getOngoingPromo(ids: [widget.merchantID]);
    return res.categorize();
  });
  final DateFormat format = DateFormat('dd MMM yyyy');
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(provider);
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () async {
                await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              )),
                          child: SafeArea(
                            top: false,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 60,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: textField,
                                      ),
                                    ),
                                  ),
                                  const Gap(15),
                                  Center(
                                      child: Text(
                                    "Common FAQs",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                  const Gap(15),
                                  Text(
                                    "How to use?",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(5),
                                  Text(
                                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse elit ligula, porta nec libero eu, dictum sodales mi. Nulla facilisi. Aenean maximus quam ac tellus condimentum varius.",
                                  )
                                ],
                              ),
                            ),
                          ),
                        ));
              },
              icon: Icon(
                Icons.info,
                color: grey,
              ))
        ],
        title: Text(
          "Promo code",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: result.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/rider.png",
                    height: 120,
                  ),
                  const Gap(20),
                  Text("No promos generated yet.")
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemBuilder: (_, i) {
              final CategorizedPromoModel model = data[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.promoTypeString,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Gap(10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, ii) {
                      final PromoModel promo = model.promos[ii];
                      return GestureDetector(
                        onTap: () {
                          widget.onPromoSelected(promo);
                          Navigator.of(context).pop();
                        },
                        child: ClipPath(
                          clipper: TicketClipper(),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      promo.promoType == 1
                                          ? "Free Delivery"
                                          : "Rewards: ${promo.valueType == 1 ? "₱" : ""}${promo.value.toInt()}${promo.valueType == 2 ? "%" : ""} OFF",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "${promo.valueType == 1 ? "₱" : ""}${promo.valueType == 1 ? promo.value.toStringAsFixed(2) : promo.value.toInt()}${promo.valueType == 2 ? "%" : ""}",
                                      style: TextStyle(
                                        fontFamily: "",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  promo.promoCode,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: grey,
                                  ),
                                ),
                                const Gap(15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      promo.minimumOrderAmount > 0
                                          ? "₱ ${promo.minimumOrderAmount.toStringAsFixed(2)} minimum"
                                          : "No minimum order",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Valid until ${format.format(promo.endDate).toLowerCase()}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: textField,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, ii) => const Gap(10),
                    itemCount: model.promos.length,
                  )
                ],
              );
            },
            separatorBuilder: (_, i) => const Gap(20),
            itemCount: data.length,
          );
        },
        error: (error, s) => Container(),
        loading: () => Center(
          child: CustomLoader(
            color: darkGrey,
            label: "Fetching promo codes",
          ),
        ),
      ),
    );
  }
}
