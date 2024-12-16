import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/feedback/customer_feedback.dart';
import 'package:nomnom/models/feedback/store_feedback.dart';

class StoreReviewViewer extends ConsumerStatefulWidget {
  const StoreReviewViewer(
      {super.key, required this.provider, required this.onSizeChanged});
  final FutureProvider<StoreFeedback> provider;
  final ValueChanged<Size> onSizeChanged;
  @override
  ConsumerState<StoreReviewViewer> createState() => _StoreReviewViewerState();
}

class _StoreReviewViewerState extends ConsumerState<StoreReviewViewer>
    with ColorPalette {
  final GlobalKey _key = GlobalKey();
  Size _oldSize = Size(0, 0);
  void _notifySize() async {
    //
    final size = _key.currentContext!.size;
    if (_oldSize != size && size != null) {
      _oldSize = size;
      print("NEW SIZE : $size");
      await Future.delayed(1000.ms);
      setState(() {});
      // widget.onSizeChanged(size);
    }
  }

  final DateFormat format = DateFormat('MMMM dd, yyyy');

  listener() {
    ref.listenManual(widget.provider, (s, n) async {
      if (n.hasValue) {
        print("MAYDA NA DATA");
        _notifySize();
      }
    });
    // final f = ref.watch(widget.provider);
    // f.whenData((s) {
    //   print("MAYDA NA DATA");
    // });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _notifySize();
      listener();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final res = ref.watch(widget.provider);

    return Container(
      key: _key,
      child: res.when(
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reviews",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (data.feedbacks.isEmpty) ...{
                  const Gap(20),
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            "assets/images/rider.png",
                            height: 120,
                          ),
                          const Gap(10),
                          Text("No reviews yet.")
                        ],
                      ),
                    ),
                  )
                } else ...{
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    itemBuilder: (_, i) {
                      final CustomerFeedback feedback = data.feedbacks[i];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feedback.customer.email.obscureEmail(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  format.format(feedback.createdAt),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(.4)),
                                ),
                                const Gap(5),
                                Text(
                                  feedback.feedback,
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          const Gap(10),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: orangePalette,
                                size: 18,
                              ),
                              Text(
                                feedback.rate.toStringAsFixed(1),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              )
                            ],
                          )
                        ],
                      );
                    },
                    separatorBuilder: (_, i) => const Gap(10),
                    itemCount: data.feedbacks.length,
                  )
                },
              ],
            ),
          );
        },
        error: (e, s) => Container(),
        loading: () {
          return SizedBox(
            height: 250,
            child: Center(
              child: CustomLoader(
                label: "Fetching store reviews",
                color: Colors.black.withOpacity(.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
