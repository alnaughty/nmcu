import 'package:flutter/material.dart';
import 'package:nomnom/app/widgets/dashed_line_painter.dart';

class DashedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashHeight;
  final double spaceWidth;
  final Color color;

  const DashedDivider({
    Key? key,
    this.dashWidth = 8.0,
    this.dashHeight = 2.0,
    this.spaceWidth = 4.0,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: CustomPaint(
        size: Size(double.infinity, dashHeight), // Full-width and dashHeight
        painter: DashedLinePainter(
          dashWidth: dashWidth,
          dashHeight: dashHeight,
          spaceWidth: spaceWidth,
          color: color,
        ),
      ),
    );
  }
}
