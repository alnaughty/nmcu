import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';

class PickerPin extends ConsumerStatefulWidget {
  const PickerPin({
    super.key,
    this.size = 40,
    this.color = const Color(0xFF8967B3),
  });
  final double size;
  final Color color;
  @override
  ConsumerState<PickerPin> createState() => _PickerPinState();
}

class _PickerPinState extends ConsumerState<PickerPin> with ColorPalette {
  @override
  Widget build(BuildContext context) {
    final Color textColor = darkGrey;
    // final bool darkMode = ref.watch(darkModeProvider);
    return SizedBox(
      height: widget.size * 1.3,
      width: widget.size,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: widget.size * .05,
                height: widget.size * .5,
                // color: !darkMode ? pastelPurple : Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: widget.size,
              height: widget.size * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: orangePalette,
              ),
              padding: EdgeInsets.all(widget.size * .2),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, c) => Container(
                    decoration: BoxDecoration(
                      color: orangePalette.lighten(),
                      shape: BoxShape.circle,
                    ),
                    height: c.maxHeight,
                    width: c.maxWidth,
                    padding: EdgeInsets.all(widget.size * .1),
                    child: Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        color: Colors.white,
                      )
                          .animate(
                            autoPlay: true,
                            onPlay: (controller) =>
                                controller.repeat(reverse: false),
                          )
                          .rotate(
                            duration: 3.seconds,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // color: Colors.red,
      // child: Column(
      //   children: [

      //     Expanded(
      //       child: Center(
      // child: Container(
      //   width: widget.size * .05,
      //   color: textColor,
      // ),
      //       ),
      //     )
      //   ],
      // ),
    );
  }
}
