import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/merchant/promo.dart';

class StorePromoViewer extends ConsumerStatefulWidget {
  const StorePromoViewer(
      {super.key, required this.provider, required this.onSizeChanged});
  final FutureProvider<List<PromoModel>> provider;
  final ValueChanged<Size> onSizeChanged;
  @override
  ConsumerState<StorePromoViewer> createState() => _StorePromoViewerState();
}

class _StorePromoViewerState extends ConsumerState<StorePromoViewer> {
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(widget.provider);
    return result.when(
      data: (data) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemBuilder: (_, i) {
            final PromoModel promo = data[i];
            return Text(promo.promoCode);
          },
          separatorBuilder: (_, i) => const Gap(10),
          itemCount: data.length,
        );
      },
      error: (e, s) => Container(),
      loading: () {
        return SizedBox(
          height: 250,
          child: Center(
            child: CustomLoader(
              label: "Fetching store promos",
              color: Colors.black.withOpacity(.5),
            ),
          ),
        );
      },
    );
  }
}
