import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/mixins/color_palette.dart';

// ignore: must_be_immutable
class CustomRadioButton extends StatefulWidget {
  CustomRadioButton(
      {super.key,
      required this.currentState,
      required this.callback,
      this.withSplash = false,
      this.style = const TextStyle(
        fontWeight: FontWeight.w500,
      ),
      required this.label});
  bool currentState;
  final ValueChanged<bool> callback;
  final String label;
  final TextStyle style;
  final bool withSplash;
  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton>
    with ColorPalette {
  // late bool isEnabled = widget.currentState;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: widget.withSplash ? null : Colors.transparent,
      onTap: () {
        setState(() {
          widget.currentState = !widget.currentState;
        });
        widget.callback(widget.currentState);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            widget.currentState
                ? Container(
                    width: 20,
                    height: 20,
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: orangePalette, width: 3),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: orangePalette),
                    ),
                  )
                : Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: grey, width: 3),
                    ),
                  ),
            const Gap(10),
            Text(widget.label, style: widget.style)
          ],
        ),
      ),
    );
  }
}
