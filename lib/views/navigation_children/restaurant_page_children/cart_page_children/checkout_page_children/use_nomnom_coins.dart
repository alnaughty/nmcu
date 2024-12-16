import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/providers/user_providers.dart';

class UseNomnomCoins extends ConsumerStatefulWidget {
  const UseNomnomCoins({super.key, required this.pointsCallback});
  final ValueChanged<int> pointsCallback;
  @override
  ConsumerState<UseNomnomCoins> createState() => _UseNomnomCoinsState();
}

class _UseNomnomCoinsState extends ConsumerState<UseNomnomCoins>
    with ColorPalette {
  bool isEnabled = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double points = ref.watch(clientPointProvider);
      widget.pointsCallback(points.floor());
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double points = ref.watch(clientPointProvider);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isEnabled = !isEnabled;
              });
              if (isEnabled) {
                widget.pointsCallback(points.floor());
              } else {
                widget.pointsCallback(0);
              }
              // setState(() {
              //   if (nomnomPointsUsed == 0) {
              //     if (points < 5) {
              //       Fluttertoast.showToast(msg: "Cannot use points yet");
              //       return;
              //     }
              //     nomnomPointsUsed = points;
              //   } else {
              //     nomnomPointsUsed = 0.0;
              //   }
              // });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: !isEnabled ? textField : orangePalette,
              ),
              child: Text(
                "${points.floor()}pts",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Gap(15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Use nomnom coins?",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "₱${points.floor()} will be deducted from your total",
                  style: TextStyle(
                    fontSize: 12,
                    color: grey,
                    fontFamily: "",
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
