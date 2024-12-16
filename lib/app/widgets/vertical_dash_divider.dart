import 'package:flutter/material.dart';

class VerticalDashDivider extends StatelessWidget {
  final double height;
  final double dashHeight;
  final double dashWidth;
  final double spacing;
  final Color color;

  const VerticalDashDivider({
    Key? key,
    required this.height,
    this.dashHeight = 5,
    this.dashWidth = 2,
    this.spacing = 3,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashCount =
              (constraints.maxHeight / (dashHeight + spacing)).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return Container(
                width: dashWidth,
                height: dashHeight,
                color: color,
              );
            }),
          );
        },
      ),
    );
  }
}
